Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6780F2806EF
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 18:55:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z195so479228wmz.8
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 15:55:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x42si62167wrb.449.2017.08.22.15.55.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 15:55:33 -0700 (PDT)
Date: Tue, 22 Aug 2017 15:55:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 196729] New: System becomes unresponsive when swapping -
 Regression since 4.10.x
Message-Id: <20170822155530.928b377fa636bbea28e1d4df@linux-foundation.org>
In-Reply-To: <bug-196729-27@https.bugzilla.kernel.org/>
References: <bug-196729-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: netwiz@crc.id.au, bugzilla-daemon@bugzilla.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 22 Aug 2017 11:17:08 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=196729
> 
>             Bug ID: 196729
>            Summary: System becomes unresponsive when swapping - Regression
>                     since 4.10.x
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.11.x / 4.12.x
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: netwiz@crc.id.au
>         Regression: No

So it's "Regression: yes".  More info at the bugzilla link.

> I have 10Gb of RAM in this system and run Fedora 26. If I launch Cities: 
> Skylines with no swap space, things run well performance wise until I get an 
> OOM - and it all dies - which is expected.
> 
> When I turn on swap to /dev/sda2 which resides on an SSD, I get complete 
> system freezes while swap is being accessed.
> 
> The first swap was after loading a saved game, then launching kmail in the 
> background. This caused ~500Mb to be swapped to /dev/sda2 on an SSD. The 
> system froze for about 8 minutes - barely being able to move the mouse. The 
> HDD LED was on constantly during the entire time.
> 
> To hopefully rule out the above glibc issue, I started the game via jemalloc - 
> but experienced even more severe freezes while swapping. I gave up waiting 
> after 13 minutes of non-responsiveness - not even being able to move the mouse 
> properly.
> 
> During these hangs, I could typed into a Konsole window, and some of the 
> typing took 3+ minutes to display on the screen (yay for buffers?).
> 
> I have tested this with both the default vm.swappiness values, as well as the 
> following:
> vm.swappiness = 1
> vm.min_free_kbytes = 32768
> vm.vfs_cache_pressure = 60
> 
> I noticed that when I do eventually get screen updates, all 8 cpus (4 cores / 
> 2 threads) show 100% CPU usage - and kswapd is right up there in the process 
> list for CPU usage. Sadly I haven't been able to capture this information 
> fully yet due to said unresponsiveness.
> 
> (more to come in comments & attachments)
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
