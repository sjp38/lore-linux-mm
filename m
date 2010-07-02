Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 843D26B01AC
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 19:05:08 -0400 (EDT)
Date: Fri, 2 Jul 2010 16:05:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16321] New: os unresponsive during buffered
 I/O
Message-Id: <20100702160501.45861821.akpm@linux-foundation.org>
In-Reply-To: <bug-16321-10286@https.bugzilla.kernel.org/>
References: <bug-16321-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Thu, 1 Jul 2010 11:57:37 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16321
> 
>            Summary: os unresponsive during buffered I/O
>            Product: IO/Storage
>            Version: 2.5
>     Kernel Version: 2.6.34
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Block Layer
>         AssignedTo: axboe@kernel.dk
>         ReportedBy: rrs@researchut.com
>         Regression: No
> 
> 
> I have been running these tests on my laptop running the 2.6.34 Debian kernel.
> When doing buffered I/O, the OS completely stalls to any interactivity. I
> cannot switch console tabs in my Desktop Environment and the mouse pointer does
> not move.
> 
> Eventually, I/O completes and every thing resumes to normal. There is no OOM
> seen during the I/O operation.
> If doing direct I/O, interactivity does not get penalized.
> 

1...

2...

3...

FUCK!!!

We've been trying to fix this stuff for ten years.  Apparently, without
success.  Do we suck, or what?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
