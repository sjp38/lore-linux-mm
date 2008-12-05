Message-Id: <6.2.5.6.2.20081205124907.01c38670@binnacle.cx>
Date: Fri, 05 Dec 2008 12:49:10 -0500
From: starlight@binnacle.cx
Subject: Re: [Bug 12134] New: can't shmat() 1GB hugepage segment
   from second process more than one time
In-Reply-To: <1228497450.13428.26.camel@localhost.localdomain>
References: <bug-12134-27@http.bugzilla.kernel.org/>
 <20081201181459.49d8fcca.akpm@linux-foundation.org>
 <1228245880.13482.19.camel@localhost.localdomain>
 <6.2.5.6.2.20081203221021.01cf8e88@binnacle.cx>
 <1228497450.13428.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, Andy Whitcroft <apw@shadowen.org>, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>

At 11:17 12/5/2008 -0600, you wrote:
>On Wed, 2008-12-03 at 22:15 -0500, starlight@binnacle.cx wrote:
>> At 13:24 12/2/2008 -0600, Adam Litke wrote:
>> >starlight@binnacle.cx:  I need more information
>> >to reproduce this bug.
>> 
>> I'm too swamped to build a test-case, but here are straces
>> that show the relevant system calls and the failure.
>
>Starlight,
>
>Thanks for the strace output.  As I suspected, this is more 
>complex than it first appeared.  There are several hugetlb 
>shared memory segments involved.  Couple that with threading and 
>an interesting approach to mlocking the address space and I've 
>got a very difficult to reproduce scenario.  Is it 
>possible/practical for me to have access to your program?

Sorry, I'm not permitted to share the code.

The program fork/execs a script in addition to creating many 
worker threads (have contemplated switching to 'pthread_spawn()', 
but it seems it does a fork/exec anyway).  I wonder if that has 
anything to do with it.  Will try disabling that and then 
disabling the 'mlock()' calls to see if either eliminates
the issue.   Doubt that worker thread creation is a factor.

>If so, I could quickly bisect the kernel and identify the guilty 
>patch.  Without the program, I am left stabbing in the dark. 
>Could you try on a 2.6.18 kernel to see if it works or not?  
>Thanks.

Any particular version of 2.6.18?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
