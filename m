Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8ABE96B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 03:22:50 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id e128so116646023pfe.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 00:22:50 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id 67si39839359pfh.155.2016.04.04.00.22.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 00:22:49 -0700 (PDT)
Message-ID: <1459754566.19748.9.camel@kernel.org>
Subject: /proc/meminfo question
From: Ming Lin <mlin@kernel.org>
Date: Mon, 04 Apr 2016 00:22:46 -0700
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: fengguang.wu@intel.com

Hi,

I'm debugging a memory leak in an internal driver.
There is ~2G leak after stress tests.

If I read below /proc/meminfo correctly, it doesn't show where the 2G
memory is possibly used.

Buffers + Cached + Active*/Inactive* + Slab* only about 300M.

Is there other statistics not shown in /proc/meminfo or am I missing
obvious things?

root@target:~# uname -r
4.5.0+

root@target:~# echo 3 > /proc/sys/vm/drop_cachesA 

root@target:~# free
A A A A A A A A A A A A A totalA A A A A A A usedA A A A A A A freeA A A A A sharedA A A A buffersA A A A A cached
Mem:A A A A A A A 3787612A A A A 2182128A A A A 1605484A A A A A A A 1072A A A A A A A 1036A A A A A A 24240
-/+ buffers/cache:A A A A 2156852A A A A 1630760
Swap:A A A A A 15624188A A A A A A A 6812A A A 15617376

root@target:~# cat /proc/meminfoA 
MemTotal:A A A A A A A A 3787612 kB
MemFree:A A A A A A A A A 1604336 kB
MemAvailable:A A A A 1598460 kB
Buffers:A A A A A A A A A A A A 1928 kB
Cached:A A A A A A A A A A A A 24668 kB
SwapCached:A A A A A A A A A 1344 kB
Active:A A A A A A A A A A A A 27520 kB
Inactive:A A A A A A A A A A 14184 kB
Active(anon):A A A A A A 12504 kB
Inactive(anon):A A A A A 3752 kB
Active(file):A A A A A A 15016 kB
Inactive(file):A A A A 10432 kB
Unevictable:A A A A A A A A A A A 0 kB
Mlocked:A A A A A A A A A A A A A A A 0 kB
SwapTotal:A A A A A A 15624188 kB
SwapFree:A A A A A A A 15617376 kB
Dirty:A A A A A A A A A A A A A A A A 36 kB
Writeback:A A A A A A A A A A A A A 0 kB
AnonPages:A A A A A A A A A 14656 kB
Mapped:A A A A A A A A A A A A 23328 kB
Shmem:A A A A A A A A A A A A A A 1072 kB
Slab:A A A A A A A A A A A A A A 94092 kB
SReclaimable:A A A A A A 12324 kB
SUnreclaim:A A A A A A A A 81768 kB
KernelStack:A A A A A A A A 3344 kB
PageTables:A A A A A A A A A 2936 kB
NFS_Unstable:A A A A A A A A A A 0 kB
Bounce:A A A A A A A A A A A A A A A A 0 kB
WritebackTmp:A A A A A A A A A A 0 kB
CommitLimit:A A A A 17517992 kB
Committed_AS:A A A A A 155592 kB
VmallocTotal:A A A 34359738367 kB
VmallocUsed:A A A A A A A A A A A 0 kB
VmallocChunk:A A A A A A A A A A 0 kB
HardwareCorrupted:A A A A A 0 kB
AnonHugePages:A A A A A A A A A 0 kB
CmaTotal:A A A A A A A A A A A A A A 0 kB
CmaFree:A A A A A A A A A A A A A A A 0 kB
HugePages_Total:A A A A A A A 0
HugePages_Free:A A A A A A A A 0
HugePages_Rsvd:A A A A A A A A 0
HugePages_Surp:A A A A A A A A 0
Hugepagesize:A A A A A A A 2048 kB
DirectMap4k:A A A A A A 205648 kB
DirectMap2M:A A A A A 3872768 kBA 

root@target:~# page-typesA 
A A A A A A A A A A A A A flags	page-countA A A A A A A MBA A symbolic-flags			long-symbolic-flags
0x0000000000000000	A A A 1007923A A A A A 3937A A _________________________________________	
0x0000000001000000	A A A A A A A A A 1A A A A A A A A 0A A ________________________z________________	zero_page
0x0000000000100000	A A A A 131072A A A A A A 512A A ____________________n____________________	nopage
0x0000000000000008	A A A A A A A A A 1A A A A A A A A 0A A ___U_____________________________________	uptodate
0x0000000000000020	A A A A A A A A 32A A A A A A A A 0A A _____l___________________________________	lru
0x0000000000000024	A A A A A A A A 14A A A A A A A A 0A A __R__l___________________________________	referenced,lru
0x0000000000000028	A A A A A A A 142A A A A A A A A 0A A ___U_l___________________________________	uptodate,lru
0x0000000000004028	A A A A A A A 102A A A A A A A A 0A A ___U_l________b__________________________	uptodate,lru,swapbacked
0x000000000000002c	A A A A A A A A 39A A A A A A A A 0A A __RU_l___________________________________	referenced,uptodate,lru
0x0000000000000040	A A A A A A A A 15A A A A A A A A 0A A ______A__________________________________	active
0x0000000000000060	A A A A A A A 450A A A A A A A A 1A A _____lA__________________________________	lru,active
0x0000000000000064	A A A A A A A A 80A A A A A A A A 0A A __R__lA__________________________________	referenced,lru,active
0x0000000000000068	A A A A A A A A 21A A A A A A A A 0A A ___U_lA__________________________________	uptodate,lru,active
0x000000000000006c	A A A A A A A A 52A A A A A A A A 0A A __RU_lA__________________________________	referenced,uptodate,lru,active
0x0000000000000080	A A A A A 10471A A A A A A A 40A A _______S_________________________________	slab
0x0000000000006228	A A A A A A A A 28A A A A A A A A 0A A ___U_l___I___sb__________________________	uptodate,lru,reclaim,swapcache,swapbacked
0x0000000000000228	A A A A A A A A A 6A A A A A A A A 0A A ___U_l___I_______________________________	uptodate,lru,reclaim
0x0000000000004238	A A A A A A A 162A A A A A A A A 0A A ___UDl___I____b__________________________	uptodate,dirty,lru,reclaim,swapbacked
0x0000000000004278	A A A A A A A A A 2A A A A A A A A 0A A ___UDlA__I____b__________________________	uptodate,dirty,lru,active,reclaim,swapbacked
0x0000000000000800	A A A A A A A A A 1A A A A A A A A 0A A ___________M_____________________________	mmap
0x0000000000000804	A A A A A A A A A 1A A A A A A A A 0A A __R________M_____________________________	referenced,mmap
0x0000000000000808	A A A A A A A A A 4A A A A A A A A 0A A ___U_______M_____________________________	uptodate,mmap
0x0000000000000828	A A A A A A 1871A A A A A A A A 7A A ___U_l_____M_____________________________	uptodate,lru,mmap
0x000000000000082c	A A A A A A A 668A A A A A A A A 2A A __RU_l_____M_____________________________	referenced,uptodate,lru,mmap
0x0000000000004838	A A A A A A A A A 2A A A A A A A A 0A A ___UDl_____M__b__________________________	uptodate,dirty,lru,mmap,swapbacked
0x0000000000000868	A A A A A A A 607A A A A A A A A 2A A ___U_lA____M_____________________________	uptodate,lru,active,mmap
0x000000000000086c	A A A A A A 2754A A A A A A A 10A A __RU_lA____M_____________________________	referenced,uptodate,lru,active,mmap
0x0000000000000c00	A A A A A 12532A A A A A A A 48A A __________BM_____________________________	buddy,mmap
0x0000000000007028	A A A A A A A 105A A A A A A A A 0A A ___U_l______asb__________________________	uptodate,lru,anonymous,swapcache,swapbacked
0x0000000000005048	A A A A A A A A A 8A A A A A A A A 0A A ___U__A_____a_b__________________________	uptodate,active,anonymous,swapbacked
0x0000000000007068	A A A A A A A A A 7A A A A A A A A 0A A ___U_lA_____asb__________________________	uptodate,lru,active,anonymous,swapcache,swapbacked
0x0000000000007228	A A A A A A A A A 6A A A A A A A A 0A A ___U_l___I__asb__________________________	uptodate,lru,reclaim,anonymous,swapcache,swapbacked
0x0000000000007828	A A A A A A A 146A A A A A A A A 0A A ___U_l_____Masb__________________________	uptodate,lru,mmap,anonymous,swapcache,swapbacked
0x0000000000005838	A A A A A A A 380A A A A A A A A 1A A ___UDl_____Ma_b__________________________	uptodate,dirty,lru,mmap,anonymous,swapbacked
0x0000000000005848	A A A A A A A A A 6A A A A A A A A 0A A ___U__A____Ma_b__________________________	uptodate,active,mmap,anonymous,swapbacked
0x0000000000005868	A A A A A A 3084A A A A A A A 12A A ___U_lA____Ma_b__________________________	uptodate,lru,active,mmap,anonymous,swapbacked
0x0000000000007868	A A A A A A A A 10A A A A A A A A 0A A ___U_lA____Masb__________________________	uptodate,lru,active,mmap,anonymous,swapcache,swapbacked
0x000000000000586c	A A A A A A A A A 7A A A A A A A A 0A A __RU_lA____Ma_b__________________________	referenced,uptodate,lru,active,mmap,anonymous,swapbacked
0x000000000000786c	A A A A A A A A 26A A A A A A A A 0A A __RU_lA____Masb__________________________	referenced,uptodate,lru,active,mmap,anonymous,swapcache,swapbacked
0x0000000000005878	A A A A A A A 126A A A A A A A A 0A A ___UDlA____Ma_b__________________________	uptodate,dirty,lru,active,mmap,anonymous,swapbacked
0x000000000000787c	A A A A A A A A A 1A A A A A A A A 0A A __RUDlA____Masb__________________________	referenced,uptodate,dirty,lru,active,mmap,anonymous,swapcache,swapbacked
0x0000000000007a28	A A A A A A A A A 9A A A A A A A A 0A A ___U_l___I_Masb__________________________	uptodate,lru,reclaim,mmap,anonymous,swapcache,swapbacked
0x0000000000005a38	A A A A A A A A A 8A A A A A A A A 0A A ___UDl___I_Ma_b__________________________	uptodate,dirty,lru,reclaim,mmap,anonymous,swapbacked
0x0000000000007a68	A A A A A A A A A 1A A A A A A A A 0A A ___U_lA__I_Masb__________________________	uptodate,lru,active,reclaim,mmap,anonymous,swapcache,swapbacked
0x0000000000005a78	A A A A A A A A A 9A A A A A A A A 0A A ___UDlA__I_Ma_b__________________________	uptodate,dirty,lru,active,reclaim,mmap,anonymous,swapbacked
A A A A A A A A A A A A A total	A A A 1172992A A A A A 4582
root@target:~#A 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
