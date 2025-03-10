---
layout: post
title: Using a condition variable in C++
comments: true
slug: cpp-condition-variable
summary: "A C++ example of using a conditional variable and a mutex."
date: "2021-07-14"
tags: [c++, programming, concurrency]
---

A condition variable (`std::condition_variable` from the `<condition_variable>` header) is an abstraction allowing for one or multiple threads to wait on an event associated with modification of some shared variable.

As an example, consider two threads, denoted the **publisher** and the **subscriber**. The former generates a series of events, with some associated data. The latter subscribes to these events and processes the data elements as they become available. For making this possible, we will use the global mutex and condition variable:

```c++
std::condition_variable cond;
std::mutex mx;
```

Let's simulate the **publisher** scenario as follows: the publisher generates a random integer betwen 0 and 25, denoted as `value`. It then sleeps for `value` seconds. Afher the sleeping period, it puts `value` on the queue and lets the subscriber know about it. Here is the logic of such event genreation loop:

```c++
void generate_events(std::queue<unsigned int>& q) {

    std::random_device rd{};
    std::default_random_engine generator{rd()};
    std::uniform_int_distribution<unsigned int> distrib{0, 25};

    for (;;) {

        auto value = distrib(generator);
        std::this_thread::sleep_for(std::chrono::seconds(value));

        std::cout << "[generator] Slept for " << value << " seconds";
        std::cout << std::endl;

        std::lock_guard<std::mutex> lock{mx};
        q.push(value);
        cond.notify_one();
        
    }
}
```

The most interesting are the three last lines within the body of the loop. First, a lock is created to restrict a mutually-exclusive access to the queue. Then, the value is pushed on the queue, and the subscriber thread is notified via the condition variable. Going out the scope releases the lock.

Let's now look at how the **subscriber** is implemented:

```c++
void process_events(std::queue<unsigned int>& q) {

    for (;;) {

        std::unique_lock<std::mutex> lock{mx};

        cond.wait(
            lock,
            [&q]{return !q.empty();}
        );

        auto value = q.front();
        q.pop();

        lock.unlock();

        std::cout << "[subscriber] Received " << value << std::endl;

    }

}
```

Before using the condition variable in each iteration of the loop, a lock object of the type `std::unique_lock` is created. It allows for on-demand locking/unclocking, which will come in handy when waiting on the conditin variable. The latter process is realized with the method call involving the lock and a predicate lambda:

```c++
cond.wait(
    lock,
    [&q]{return !q.empty();} // predicate
);
```

This particular call is equivalent to the following snippet (which is a bit more low-level, but allows for getting a better grasp on the pricinple of how the waiting on a condition variable happens):

```c++

while (q.empty()) { // !predicate
    cond.wait(lock);
}
```

Keep in mind that right before this loop, a lock is acquired, so it is safe to check the status of the queue. The first check is always done: if `predicate == true` (in our case, the queue is not empty), then we are good to go, and can proceed to retrieving the front element from it. Otherwise, which is a more common case, the lock is released and the wait operation blocks until the publisher thread notifies about the event. 

It is important to note that the wait operation may unblock several times before the actual event happens (the so-called **spurious wakes**). On each wake, either spurious or resulting from `notify_one`, the lock is re-acuired to allow checking the condition. 

The full example desctribed in this post can be found on [Github](https://github.com/semeniuta/demo_cpp/blob/master/src/demo_condvar.cpp). To actually observe how many times the condition is checked, I have modified the code as follows

```c++
int count = 0;

cond.wait(
    lock,
    [&q, &count]{
        std::cout << "[condvar] Checking " << ++count << std::endl; 
        return !q.empty();
    }
);
```

As a reference to this example, I have used chapter 4 of "[C++ Concurrency in Action](https://www.manning.com/books/c-plus-plus-concurrency-in-action-second-edition)" and chapter 42 of "[The C++ Programming Language](https://www.stroustrup.com/4th.html)".