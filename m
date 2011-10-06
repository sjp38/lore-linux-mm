Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 987856B0261
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 05:00:30 -0400 (EDT)
Received: by wyf22 with SMTP id 22so3452304wyf.14
        for <linux-mm@kvack.org>; Thu, 06 Oct 2011 02:00:26 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 6 Oct 2011 18:00:26 +0900
Message-ID: <CAFPAmTQnKv_kQBHP_97fwkEAF0b-QmcqH-1=v5Ce6kSgFe1TUw@mail.gmail.com>
Subject: Query about coredump image generation for multi-threaded apps.
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: chungki0201.woo@samsung.com

Dear All,

We are running a multi-threaded embedded application on a uniprocessor
ARM system.

We encountered a memory corruption due to which the application crashed.
The crashing thread accessed a pointer variable whose value was
corrupted and so the
application crashed.

However, there are multiple threads writing to that corrupted pointer
variable at the same instant
as the crash occurs on the crashing thread.
( As per the application logic, only proper writeable virtual memory
addresses are written to that
  variable, so this is a random corruption from some other module in
the process virtual address
  space. )

The result is that the coredump image generated does not contain the
same corrupted value inside
the pointer variable.

Also, various other variables' values are changed as a result of the
delay between the actual crash
and the actions of other threads on the shared global variables.

Query:
=====
Is there any way we can get the image of the process virtual memory in
the coredump at the exact time
of crash ?
Can someone describe possible solutions or workarounds to this problem
for both uniprocessor and SMP
systems ?

Note:
-------
I understand that this problem probably won't happen if we use a
pthread_mutex to protect those global
variables.
In that event, if there is a crash, the other threads will not be able
to access the shared global variables
as the mutex would not have been released.
However, this is currently not an option for us due to certain official reasons.
We would appreciate it if someone could find a way to solve this
without having to introduce any
pthread_mutexes.

Thanks,
Kautuk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
