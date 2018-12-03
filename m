Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 312496B6B42
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 16:54:55 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 89so11056130ple.19
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 13:54:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h20si12948921pgm.366.2018.12.03.13.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 13:54:53 -0800 (PST)
Date: Mon, 3 Dec 2018 13:54:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 201865] New: BUG: Bad rss-counter state
 mm:00000000d5ef1295 idx:1 val:3
Message-Id: <20181203135450.6b14e4fe678fd84a34035c70@linux-foundation.org>
In-Reply-To: <bug-201865-27@https.bugzilla.kernel.org/>
References: <bug-201865-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, erhard_f@mailbox.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 03 Dec 2018 18:27:24 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=201865
> 
>             Bug ID: 201865
>            Summary: BUG: Bad rss-counter state mm:00000000d5ef1295 idx:1
>                     val:3
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.20-rc5
>           Hardware: PPC-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: erhard_f@mailbox.org
>         Regression: No
> 
> Created attachment 279823
>   --> https://bugzilla.kernel.org/attachment.cgi?id=279823&action=edit
> dmesg output
> 
> The kernel (4.20-rc5) tells me:
> 
> [  873.263594] BUG: Bad rss-counter state mm:00000000d5ef1295 idx:1 val:3
> [  873.263605] BUG: non-zero pgtables_bytes on freeing mm: 24576
> 
> I've seen bug #196569, but I am not quite sure if this is the same problem. So
> filing a new bug.
> 
> Machine is a Talos II, dual-socket NUMA 4-core POWER9:
> 
> # cat /proc/buddyinfo 
> Node 0, zone      DMA 166543 151725 106193  58527  20325   4948    914    143  
>   11      2      0      2      7 
> Node 8, zone      DMA 229945 211748 103714  40310  16707   6915   1726    284  
>   34      4      1      2     79 
> # cat /proc/meminfo 
> MemTotal:       32769896 kB
> MemFree:        17302532 kB
> MemAvailable:   25725428 kB
> Buffers:           39732 kB
> Cached:          8185260 kB
> SwapCached:            0 kB
> Active:          4121112 kB
> Inactive:        3958012 kB
> Active(anon):      69728 kB
> Inactive(anon):      192 kB
> Active(file):    4051384 kB
> Inactive(file):  3957820 kB
> Unevictable:      282456 kB
> Mlocked:          282456 kB
> SwapTotal:      35653624 kB
> SwapFree:       35653624 kB
> Dirty:                 0 kB
> Writeback:             0 kB
> AnonPages:        136704 kB
> Mapped:           250228 kB
> Shmem:             66504 kB
> KReclaimable:    1855456 kB
> Slab:            2187396 kB
> SReclaimable:    1855456 kB
> SUnreclaim:       331940 kB
> KernelStack:        6848 kB
> PageTables:         3408 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:    52038572 kB
> Committed_AS:     522416 kB
> VmallocTotal:   549755813888 kB
> VmallocUsed:           0 kB
> VmallocChunk:          0 kB
> Percpu:             9344 kB
> AnonHugePages:         0 kB
> ShmemHugePages:        0 kB
> ShmemPmdMapped:        0 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> Hugetlb:               0 kB
> DirectMap4k:           0 kB
> DirectMap64k:           0 kB
> DirectMap2M:     1048576 kB
> DirectMap1G:    32505856 kB
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.
