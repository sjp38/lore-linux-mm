Received: from falcon.inetnebr.com (root@falcon.inetnebr.com [199.184.119.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA21865
	for <linux-mm@kvack.org>; Fri, 21 Aug 1998 19:54:32 -0400
Received: from flinx.npwt.net (inetnebr@oma-pm1-010.inetnebr.com [206.222.220.54])
	by falcon.inetnebr.com (8.8.8/8.8.8) with ESMTP id SAA20052
	for <linux-mm@kvack.org>; Fri, 21 Aug 1998 18:53:41 -0500 (CDT)
Subject: Re: memory use in Linux
References: <3.0.3.32.19980820223733.006b4b5c@valemount.com>
From: ebiederm@inetnebr.com (Eric W. Biederman)
Date: 21 Aug 1998 18:48:22 -0500
In-Reply-To: Lonnie Nunweiler's message of Thu, 20 Aug 1998 22:37:33 -0700
Message-ID: <m1iujlj3qx.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: lonnie@valemount.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "LN" == Lonnie Nunweiler <lonnie@valemount.com> writes:

LN> I am researching why Linux runs into memory problems.  We recently had to
LN> convert our dialin server, email and web server to NT, because the Linux
LN> machine would eventually eat up all ram, and then crash.  We were using
LN> 128MB machines, and it would take about 3 days before rebooting was
LN> required.  If we didn't reboot soon enough, it was a very messy job
LN> rebuilding some of the chewed files.

Instead of running into generalities probably the best place to start is
to ask why linux ran into problems in your case.

Which kernel were you running?
What were the specifics that killed your machine?

Did it look like a kernel memory where more and more memory is eaten,
your machine begins to swap harder, and harder until death.

Or was it a user space program that leaked memory, and linux wasn't
able to cope with runing out of swap?

The cache in general is designed so anything it caches may be
reclaimed when needed. 

I think you are barking up the wrong tree so please take it slow
so the real culprit can be found.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
