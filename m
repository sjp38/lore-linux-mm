Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 54A1C6B0088
	for <linux-mm@kvack.org>; Sat,  7 Mar 2009 15:25:03 -0500 (EST)
Date: Sat, 7 Mar 2009 12:24:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-Id: <20090307122452.bf43fbe4.akpm@linux-foundation.org>
In-Reply-To: <bug-12832-27@http.bugzilla.kernel.org/>
References: <bug-12832-27@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat,  7 Mar 2009 11:27:12 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12832
> 
>            Summary: kernel leaks a lot of memory
>            Product: Memory Management
>            Version: 2.5
>      KernelVersion: 2.6.27
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@osdl.org
>         ReportedBy: drzeus-bugzilla@drzeus.cx
> 
> 
> Latest working kernel version: 2.6.26
> Earliest failing kernel version: 2.6.27
> Distribution: Fedora
> Hardware Environment: x86_64
> Software Environment: Fedora 9 & 10
> Problem Description:
> 
> Starting from 2.6.27, the kernel eats up a whole lot more of memory (hundreds
> of MB) at no gain.
> 
> I've compared what I can from 2.6.26 and so far haven't found where this
> missing memory has disappeared.
> 
> Original bug in RH's bugzilla:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=481448
> 

hm, not a lot to go on there.

We have quite a lot of instrumentation for memory consumption - were
you able to work out where it went by comparing /proc/meminfo,
/proc/slabinfo, `echo m > /proc/sysrq-trigger', etc?

Is the memory missing on initial boot up, or does it take some time for
the problem to become evident?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
