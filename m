Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DED956B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 19:57:00 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kl14so554324pab.9
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 16:57:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id vs7si18292619pbc.55.2013.11.21.16.56.59
        for <linux-mm@kvack.org>;
        Thu, 21 Nov 2013 16:56:59 -0800 (PST)
Date: Thu, 21 Nov 2013 16:56:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 65201] New: kswapd0 randomly high cpu load
Message-Id: <20131121165657.5f9a410a4162a3cabe8ee808@linux-foundation.org>
In-Reply-To: <bug-65201-27@https.bugzilla.kernel.org/>
References: <bug-65201-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nleo@nm.ru
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 19 Nov 2013 19:40:40 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=65201
> 
>             Bug ID: 65201
>            Summary: kswapd0 randomly high cpu load
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.12
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: nleo@nm.ru
>         Regression: No
> 
> kswapd0 randomly load one core of CPU by 100%
> 
> Linux localhost 3.12.0-1-ARCH #1 SMP PREEMPT Wed Nov 6 09:06:27 CET 2013 x86_64
> GNU/Linux
> 
> No swap enabled
> 
> Befor on same laptop was installed Ubuntu 12.04 and kernel 3.2 32-bit pae, and
> there is no such problem.
> 
> [root@localhost ~]# free -mh
>              total       used       free     shared    buffers     cached
> Mem:          3.8G       2.4G       1.3G         0B       150M       508M
> -/+ buffers/cache:       1.8G       2.0G
> Swap:           0B         0B         0B

hm, I wonder what kswapd is up to.

Could you please make it happen again and then

dmesg -n 7
dmesg -c
echo m > /proc/sysrq-trigger
echo t > /proc/sysrq-trigger
dmesg -s 1000000 > foo

then send us foo?

> 
> [root@localhost ~]# cat /proc/meminfo
> MemTotal:        3935792 kB
> MemFree:         1381360 kB
> Buffers:          154216 kB
> Cached:           533096 kB
> SwapCached:            0 kB
> Active:          1958896 kB
> Inactive:         438004 kB
> Active(anon):    1740916 kB
> Inactive(anon):   136292 kB
> Active(file):     217980 kB
> Inactive(file):   301712 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> SwapTotal:             0 kB
> SwapFree:              0 kB
> Dirty:              2064 kB
> Writeback:             0 kB
> AnonPages:       1709628 kB
> Mapped:           196696 kB
> Shmem:            167620 kB
> Slab:              81516 kB
> SReclaimable:      61312 kB
> SUnreclaim:        20204 kB
> KernelStack:        1696 kB
> PageTables:        13088 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:     1967896 kB
> Committed_AS:    3498576 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:      361304 kB
> VmallocChunk:   34359300731 kB
> HardwareCorrupted:     0 kB
> AnonHugePages:    157696 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> DirectMap4k:       18476 kB
> DirectMap2M:     4059136 kB
> 
> And I can't kill it. I heared that it's not good idea, but just for lulz)
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
