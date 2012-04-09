Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 3AD5D6B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 01:35:45 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so4145330bkw.14
        for <linux-mm@kvack.org>; Sun, 08 Apr 2012 22:35:43 -0700 (PDT)
Message-ID: <4F82752A.6020206@openvz.org>
Date: Mon, 09 Apr 2012 09:35:38 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: swapoff() runs forever
References: <4F81F564.3020904@nod.at>
In-Reply-To: <4F81F564.3020904@nod.at>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>

Richard Weinberger wrote:
> Hi!
>
> I'm observing a strange issue (at least on UML) on recent Linux kernels.
> If swap is being used the swapoff() system call never terminates.
> To be precise "while ((i = find_next_to_unuse(si, i)) != 0)" in try_to_unuse()
> never terminates.
>
> The affected machine has 256MiB ram and 256MiB swap.
> If an application uses more than 256MiB memory swap is being used.
> But after the application terminates the free command still reports that a few
> MiB are on my swap device and swappoff never terminates.

After last tmpfs changes swapoff can take minutes.
Or this time it really never terminates?

>
> Here some numbers:
> root@linux:~# free
>               total       used       free     shared    buffers     cached
> Mem:        255472      13520     241952          0        312       7080
> -/+ buffers/cache:       6128     249344
> Swap:       262140      17104     245036
> root@linux:~# cat /proc/meminfo
> MemTotal:         255472 kB
> MemFree:          241952 kB
> Buffers:             312 kB
> Cached:             7080 kB
> SwapCached:            0 kB
> Active:             3596 kB
> Inactive:           6076 kB
> Active(anon):       1512 kB
> Inactive(anon):      848 kB
> Active(file):       2084 kB
> Inactive(file):     5228 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> SwapTotal:        262140 kB
> SwapFree:         245036 kB
> Dirty:                 0 kB
> Writeback:             0 kB
> AnonPages:          2296 kB
> Mapped:             1824 kB
> Shmem:                80 kB
> Slab:               2452 kB
> SReclaimable:       1116 kB
> SUnreclaim:         1336 kB
> KernelStack:         192 kB
> PageTables:          556 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:      389876 kB
> Committed_AS:     238412 kB
> VmallocTotal:    3788784 kB
> VmallocUsed:          68 kB
> VmallocChunk:    3788716 kB
>
> What could cause this issue?
> I'm not sure whether this is UML specific or not.
> Maybe only UML is able to trigger the issue...
>
> Thanks,
> //richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
