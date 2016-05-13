Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3086B0005
	for <linux-mm@kvack.org>; Fri, 13 May 2016 10:35:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so10938706wme.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:35:22 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz26.laposte.net. [194.117.213.101])
        by mx.google.com with ESMTPS id q19si3987602wmb.32.2016.05.13.07.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 07:35:21 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout014 (Postfix) with ESMTP id 034BE11F246
	for <linux-mm@kvack.org>; Fri, 13 May 2016 16:35:21 +0200 (CEST)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.prosodie [10.128.63.2])
	by lpn-prd-vrout014 (Postfix) with ESMTP id E770212097D
	for <linux-mm@kvack.org>; Fri, 13 May 2016 16:35:20 +0200 (CEST)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
	by lpn-prd-vrin001 (Postfix) with ESMTP id D0341366A05
	for <linux-mm@kvack.org>; Fri, 13 May 2016 16:35:20 +0200 (CEST)
Message-ID: <5735E628.9080306@laposte.net>
Date: Fri, 13 May 2016 16:35:20 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net> <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr> <5735A3DE.9030100@laposte.net> <20160513120042.GK20141@dhcp22.suse.cz> <5735CAE5.5010104@laposte.net> <935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com> <5735D77C.9090803@laposte.net> <50852f22-6030-7361-4273-91b5bea446ed@gmail.com>
In-Reply-To: <50852f22-6030-7361-4273-91b5bea446ed@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Austin,

On 05/13/2016 03:51 PM, Austin S. Hemmelgarn wrote:
> On 2016-05-13 09:32, Sebastian Frias wrote:
>> I didn't see that in Documentation/vm/overcommit-accounting or am I looking in the wrong place?
> It's controlled by a sysctl value, so it's listed in Documentation/sysctl/vm.txt
> The relevant sysctl is vm.oom_kill_allocating_task

Thanks, I just read that.
Does not look like a replacement for overcommit=never though.

>>
>>>>
>>>> Well, it's hard to report, since it is essentially the result of a dynamic system.
>>>> I could assume it killed terminals with a long history buffer, or editors with many buffers (or big buffers).
>>>> Actually when it happened, I just turned overcommit off. I just checked and is on again on my desktop, probably forgot to make it a permanent setting.
>>>>
>>>> In the end, no processes is a good candidate for termination.
>>>> What works for you may not work for me, that's the whole point, there's a heuristic (which conceptually can never be perfect), yet the mere fact that some process has to be killed is somewhat chilling.
>>>> I mean, all running processes are supposedly there and running for a reason.
>>> OTOH, just because something is there for a reason doesn't mean it's doing what it's supposed to be.  Bugs happen, including memory leaks, and if something is misbehaving enough that it impacts the rest of the system, it really should be dealt with.
>>
>> Exactly, it's just that in this case, the system is deciding how to deal with the situation by itself.
> On a busy server where uptime is critical, you can't wait for someone to notice and handle it manually, you need the issue resolved ASAP.  Now, this won't always kill the correct thing, but if it's due to a memory leak, it often will work like it should.

The keyword is "'often' will work as expected".
So you are saying that it will kill a program leaking memory in what, like 90% of the cases?
I'm not sure if I would setup a server with critical uptime to have the OOM-killer enabled, do you think that'd be a good idea?

Anyway, as a side note, I just want to say thank you guys for having this discussion.
I think it is an interesting thread and hopefully it will advance the "knowledge" about this setting.

>>
>>>
>>> This brings to mind a complex bug involving Tor and GCC whereby building certain (old) versions of Tor with certain (old) versions of GCC with -Os would cause an infinite loop in GCC.  You obviously have GCC running for a reason, but that doesn't mean that it's doing what it should be.
>>
>> I'm not sure if I followed the analogy/example, but are you saying that the OOM-killer killed GCC in your example?
>> This seems an odd example though, I mean, shouldn't the guy in front of the computer notice the loop and kill GCC by himself?
> No, I didn't mean as an example of the OOM killer, I just meant as an example of software not doing what it should.  It's not as easy to find an example for the OOM killer, so I don't really have a good example. The general concept is the same though, the only difference is there isn't a kernel protection against infinite loops (because they aren't always bugs, while memory leaks and similar are).

So how does the kernel knows that a process is "leaking memory" as opposed to just "using lots of memory"? (wouldn't that be comparable to answering how does the kernel knows the difference between an infinite loop and one that is not?)

Best regards,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
