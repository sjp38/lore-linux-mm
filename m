Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.2 required=3.0 tests=CHARSET_FARAWAY_HEADER,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46A46C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 03:43:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C6B6218D0
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 03:43:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C6B6218D0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 067498E0004; Tue, 26 Feb 2019 22:43:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 018668E0001; Tue, 26 Feb 2019 22:43:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4A608E0004; Tue, 26 Feb 2019 22:43:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9438B8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 22:43:56 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id s22so11428649plq.7
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 19:43:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:mime-version:date:content-transfer-encoding;
        bh=lUKzzDSM7jft9A6+ovg2FttY68x8vtz4NWOmrLyc5N4=;
        b=aFmXUyMc87rwyhSVKw/7hde0JPY/4WpHVRQ792HIGO0ouAlEwMzxjn3e9J14JPaXNO
         aa/2hpuqXRVbvltC8EB8D+H4OCtRycg7qOcKB4oGRBZzqIE4J4cUTUyLsAYXYIvR2YuP
         ZzkDU/fGkMoI23SG7qk/cVWLbnUX9fzhZRxUnyszqkzGvk6NI/K01k4GOmVXMSNXugvS
         18g6vlRafhYd27VPljzFjMw+Uorys4tX+Xk5XzkLRsGQCsyuuw3N+7l9XI8wK5B3FFFF
         K4xadQspZtLDhBvb0ZS7Z9p19NfqlFvYsb0XztZ93FDzVCnhZgodI4GSmWBMjfdtuqKR
         z+ww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuZ8JYl+wiyMBAdSSdVac06Vu2oxXAIgkByHu6W5jeoEFFo7i0Zp
	J/5xj1J6P/1PkCaPdKXaG1sti7PeGoUiLBdihMTH6zd7SuGX5o4bgAICe8E7jaKjf3DMIiCcWsU
	rKFw/Wx28OlkM5YW75/6iGmFp75Aa689cwJrA7HeWkoKb1BeqE2YCNSxQpa9lbKcvKw==
X-Received: by 2002:a63:d158:: with SMTP id c24mr940503pgj.34.1551239036205;
        Tue, 26 Feb 2019 19:43:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaPzB9hA9wIYejxFCkvh2oR8ADdzChdEGxZLoHaBsOQKOt8HexNn7N/KR5RSqbwJ/M/A7OG
X-Received: by 2002:a63:d158:: with SMTP id c24mr940372pgj.34.1551239033952;
        Tue, 26 Feb 2019 19:43:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551239033; cv=none;
        d=google.com; s=arc-20160816;
        b=E1WEjFL99y67EHQkeRBM7Jqn99mUuMPeIWF7guIMi8MmqD182A/S8ho5PmQL0YXJ7A
         ih7SmBom5nfQa5GR1Ib785oKGQfdhBdEgT2Xa09/HTAz2kH7gAiz8X6mdhukW4U8n06c
         IkLRNdjo/QEmAugUyYN8e2YqMbGZ0M5GcOMdncB9oM9PTww6rDszUp/Y7RZ1MwzaCLkA
         bDuhR3Xp28xLtT5Z1rHTgqXTzztzn2MgfD2FygAEzZ2/t9QvUnjg6CI0eDBxDXbokVJc
         toqQLulbfI4b+eu1MKRDNmA8KSOGC3Elj6lQNE9IBKqRw/Xc/aeiXa/z2FWiB1tA1D5J
         LCow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:date:mime-version:to:from:subject
         :message-id;
        bh=lUKzzDSM7jft9A6+ovg2FttY68x8vtz4NWOmrLyc5N4=;
        b=ljTTv0pkCyunmDuN9R3/6t4a/tk9bYg9rMlRuEuP0t1A+82sPzLx5sUjz2pU5sLmEr
         A1lYTeFMrGz0X80Q7tSoEoXSud8l1OqdorNqoPLMMzoQv6SDQYhsEzEr+GdUWbUNmQ/L
         zqyUvfEyPgMbYEgHJOx1Wq2WRgMt0Y86++7dx+zzL/TlsCnQxlt/MAuzW+SJniy+bqJA
         UyISTixWX0JCJNreI5eimFBJhzaJ/8GCVboTG85VO30xRdouJPhGGk/V1PxHkjAKKfo3
         6aWyzV4UmlkfD0LoRxpPVnurGPp5DzU4KVI7xJuSHXjo5JAN9pTe+iEs2dlzueTjGIj9
         a4ig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g96si14882877plb.168.2019.02.26.19.43.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 19:43:53 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav304.sakura.ne.jp (fsav304.sakura.ne.jp [153.120.85.135])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1R3hpaX029626
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:43:52 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav304.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav304.sakura.ne.jp);
 Wed, 27 Feb 2019 12:43:51 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav304.sakura.ne.jp)
Received: from www262.sakura.ne.jp (localhost [127.0.0.1])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1R3hpwc029622
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:43:51 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: (from i-love@localhost)
	by www262.sakura.ne.jp (8.15.2/8.15.2/Submit) id x1R3hpZl029621;
	Wed, 27 Feb 2019 12:43:51 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Message-Id: <201902270343.x1R3hpZl029621@www262.sakura.ne.jp>
X-Authentication-Warning: www262.sakura.ne.jp: i-love set sender to penguin-kernel@i-love.sakura.ne.jp using -f
Subject: mm: Can we bail out =?ISO-2022-JP?B?cD9kX2FsbG9jKCkgbG9vcHMgdXBvbiBTSUdL?=
 =?ISO-2022-JP?B?SUxMPw==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: linux-mm@kvack.org
MIME-Version: 1.0
Date: Wed, 27 Feb 2019 12:43:51 +0900
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I noticed that when a kdump kernel triggers the OOM killer because a too
small value was given to crashkernel= parameter, the OOM reaper tends to
fail to reclaim memory from OOM victims because they are in dup_mm() from
copy_mm() from copy_process() with mmap_sem held for write. A debug dump
reported that the OOM victim was merely sleeping at might_sleep_if() in
prepare_alloc_pages() from __alloc_pages_nodemask() despite the OOM victim
is ready to bail out.

Since copy_page_range() can be called with mmap_sem held for write, it is
not a good thing to continue the loop when killed by the OOM killer.

[    9.965654] systemd-udevd invoked oom-killer: gfp_mask=0x7080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO), order=0, oom_score_adj=0
[    9.968941] CPU: 0 PID: 132 Comm: systemd-udevd Not tainted 5.0.0-rc8+ #838
[    9.970801] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[    9.973897] Call Trace:
[    9.974735]  dump_stack+0x86/0xca
[    9.975693]  dump_header+0x10a/0x9d0
[    9.976746]  ? ___ratelimit+0x1d1/0x3c5
[    9.977838]  oom_kill_process.cold.31+0xb/0x59f
[    9.979078]  ? check_flags.part.40+0x420/0x420
[    9.980727]  out_of_memory+0x287/0x800
[    9.981907]  ? oom_killer_disable+0x200/0x200
[    9.983067]  ? mutex_trylock+0x191/0x1e0
[    9.984183]  ? __alloc_pages_slowpath+0xa16/0x2380
[    9.985485]  __alloc_pages_slowpath+0x1cb2/0x2380
[    9.986767]  ? __zone_watermark_ok+0x213/0x370
[    9.988014]  ? warn_alloc+0x120/0x120
[    9.989089]  ? sched_clock_cpu+0x1b/0x170
[    9.990343]  ? __might_sleep+0x95/0x190
[    9.991569]  __alloc_pages_nodemask+0x515/0x610
[    9.992843]  ? __kasan_kmalloc.constprop.8+0xc5/0xd0
[    9.994215]  ? kasan_slab_alloc+0x11/0x20
[    9.995323]  ? __alloc_pages_slowpath+0x2380/0x2380
[    9.996649]  ? entry_SYSCALL_64_after_hwframe+0x49/0xbe
[    9.998168]  ? _raw_spin_unlock+0x22/0x30
[    9.999240]  __get_free_pages+0x14/0x90
[   10.000303]  get_zeroed_page+0x11/0x20
[   10.001391]  __pud_alloc+0x2e/0x120
[   10.002443]  copy_page_range+0xf78/0x1af0
[   10.003544]  ? sched_clock_cpu+0x1b/0x170
[   10.004658]  ? sched_clock+0x9/0x10
[   10.005646]  ? find_held_lock+0x40/0x1e0
[   10.006909]  ? check_flags.part.40+0x420/0x420
[   10.008450]  ? vma_gap_callbacks_rotate+0x5a/0x90
[   10.009766]  ? __pmd_alloc+0x370/0x370
[   10.010838]  ? __vma_link_rb+0x1fc/0x340
[   10.011963]  copy_process.part.56+0x2f0e/0x6c80
[   10.013184]  ? __cleanup_sighand+0x40/0x40
[   10.014331]  ? sched_clock_cpu+0x1b/0x170
[   10.015398]  ? find_held_lock+0x40/0x1e0
[   10.016489]  ? check_flags.part.40+0x420/0x420
[   10.017747]  _do_fork+0x15d/0xb90
[   10.018677]  ? __fd_install+0x16c/0x470
[   10.019760]  ? fork_idle+0x250/0x250
[   10.020777]  ? fd_install+0x47/0x60
[   10.021766]  ? do_pipe2+0x102/0x140
[   10.022793]  ? pci_mmcfg_check_reserved+0x120/0x120
[   10.024377]  ? trace_hardirqs_on_thunk+0x1a/0x1c
[   10.025813]  ? do_syscall_64+0x18/0x3e0
[   10.027035]  ? entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   10.029358]  __x64_sys_clone+0xba/0x140
[   10.030779]  do_syscall_64+0x8f/0x3e0
[   10.031848]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   10.033300] RIP: 0033:0x7f674d010f42
[   10.034318] Code: f7 d8 64 89 04 25 d4 02 00 00 64 4c 8b 04 25 10 00 00 00 31 d2 4d 8d 90 d0 02 00 00 31 f6 bf 11 00 20 01 b8 38 00 00 00 0f 05 <48> 3d 00 f0 ff ff 0f 87 5d 01 00 00 85 c0 41 89 c5 0f 85 67 01 00
[   10.039645] RSP: 002b:00007ffcf9331600 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
[   10.041806] RAX: ffffffffffffffda RBX: 00007ffcf9331600 RCX: 00007f674d010f42
[   10.043812] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
[   10.045766] RBP: 00007ffcf9331640 R08: 00007f674e3ef8c0 R09: 0000000000000084
[   10.047728] R10: 00007f674e3efb90 R11: 0000000000000246 R12: 0000000000000000
[   10.049685] R13: 0000000000000000 R14: 00007ffcf9333d20 R15: 00007ffcf9333920
[   10.051705] Mem-Info:
[   10.052349] active_anon:3104 inactive_anon:7316 isolated_anon:0
[   10.052349]  active_file:0 inactive_file:0 isolated_file:0
[   10.052349]  unevictable:0 dirty:0 writeback:0 unstable:0
[   10.052349]  slab_reclaimable:5033 slab_unreclaimable:13704
[   10.052349]  mapped:1177 shmem:9911 pagetables:148 bounce:0
[   10.052349]  free:479 free_pcp:41 free_cma:0
[   10.060924] Node 0 active_anon:12416kB inactive_anon:29264kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:4708kB dirty:0kB writeback:0kB shmem:39644kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[   10.069022] DMA free:508kB min:2052kB low:2052kB high:2052kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:600kB managed:516kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   10.076308] lowmem_reserve[]: 0 123 123 123
[   10.077655] DMA32 free:1408kB min:1416kB low:1768kB high:2120kB active_anon:12416kB inactive_anon:29252kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:261524kB managed:126532kB mlocked:0kB kernel_stack:2656kB pagetables:592kB bounce:0kB free_pcp:164kB local_pcp:164kB free_cma:0kB
[   10.085864] lowmem_reserve[]: 0 0 0 0
[   10.087035] DMA: 0*4kB 1*8kB (M) 1*16kB (M) 1*32kB (M) 1*64kB (U) 1*128kB (U) 1*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 504kB
[   10.090710] DMA32: 14*4kB (UME) 9*8kB (UME) 14*16kB (UME) 7*32kB (UM) 3*64kB (UME) 1*128kB (M) 2*256kB (ME) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1408kB
[   10.094751] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   10.097676] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   10.100979] 9911 total pagecache pages
[   10.102191] 0 pages in swap cache
[   10.103238] Swap cache stats: add 0, delete 0, find 0/0
[   10.104849] Free swap  = 0kB
[   10.105839] Total swap = 0kB
[   10.106846] 65531 pages RAM
[   10.107724] 0 pages HighMem/MovableOnly
[   10.108903] 33769 pages reserved
[   10.109902] 0 pages cma reserved
[   10.110915] Unreclaimable slab info:
[   10.112080] Name                      Used          Total
[   10.113686] fib6_nodes                 0KB          4KB
[   10.115512] RAWv6                     10KB         16KB
[   10.117043] sgpool-128                 8KB         31KB
[   10.118553] sgpool-64                  4KB         31KB
[   10.120101] sgpool-32                  2KB         15KB
[   10.121577] sgpool-16                  1KB          7KB
[   10.123167] sgpool-8                   1KB          7KB
[   10.124725] mqueue_inode_cache          1KB         15KB
[   10.126273] bio-1                      2KB          7KB
[   10.127752] UNIX                      67KB         90KB
[   10.129229] ip_fib_trie                1KB          3KB
[   10.130686] ip_fib_alias               1KB          3KB
[   10.132116] RAW                        3KB         30KB
[   10.133631] UDP                        2KB         30KB
[   10.135063] hugetlbfs_inode_cache          2KB         31KB
[   10.136657] eventpoll_pwq             14KB         23KB
[   10.138054] eventpoll_epi             20KB         31KB
[   10.139521] inotify_inode_mark          2KB          3KB
[   10.141039] request_queue              3KB         31KB
[   10.142472] bio-0                      2KB          7KB
[   10.143905] biovec-max                84KB        101KB
[   10.145381] bio_integrity_payload          1KB          7KB
[   10.146988] dmaengine-unmap-2          0KB          4KB
[   10.148415] audit_buffer               0KB          7KB
[   10.149869] skbuff_head_cache        244KB        311KB
[   10.151264] configfs_dir_cache          1KB          3KB
[   10.152759] fsnotify_mark_connector          2KB          3KB
[   10.154326] task_delay_info           43KB         47KB
[   10.155821] proc_dir_entry           385KB        393KB
[   10.157388] pde_opener                 1KB          7KB
[   10.158846] seq_file                  13KB         38KB
[   10.160273] sigqueue                   0KB          7KB
[   10.161766] shmem_inode_cache       1086KB       1099KB
[   10.163256] kernfs_node_cache      23189KB      23193KB
[   10.164688] mnt_cache                 30KB         31KB
[   10.166166] filp                     281KB        285KB
[   10.167596] names_cache              980KB        994KB
[   10.169095] key_jar                    3KB          7KB
[   10.170528] nsproxy                    0KB          3KB
[   10.171954] vm_area_struct           483KB        489KB
[   10.173540] mm_struct                 30KB         48KB
[   10.175039] fs_cache                   6KB         15KB
[   10.176538] files_cache               13KB         30KB
[   10.177977] signal_cache             157KB        184KB
[   10.179469] sighand_cache            217KB        252KB
[   10.180919] task_struct              592KB        626KB
[   10.182349] cred_jar                  63KB         78KB
[   10.183772] anon_vma_chain           364KB        368KB
[   10.185231] anon_vma                 121KB        137KB
[   10.186724] pid                       45KB         48KB
[   10.188546] Acpi-Operand            3938KB       4232KB
[   10.190127] Acpi-ParseExt              0KB         15KB
[   10.191627] Acpi-Parse                 0KB         15KB
[   10.193048] Acpi-State                 0KB         15KB
[   10.194670] Acpi-Namespace          3112KB       3127KB
[   10.196245] trace_event_file         241KB        243KB
[   10.197717] ftrace_event_field        553KB        554KB
[   10.199211] pool_workqueue            18KB         30KB
[   10.200701] task_group                 6KB         15KB
[   10.202331] debug_objects_cache       1675KB       1676KB
[   10.203790] page->ptl                121KB        125KB
[   10.205269] kmalloc-8k               116KB        125KB
[   10.206769] kmalloc-4k               660KB       1033KB
[   10.208563] kmalloc-2k              3480KB       3503KB
[   10.210005] kmalloc-1k               506KB        525KB
[   10.211509] kmalloc-512              413KB        493KB
[   10.212940] kmalloc-256             1042KB       1049KB
[   10.214364] kmalloc-192               96KB        103KB
[   10.215800] kmalloc-128              503KB        506KB
[   10.217203] kmalloc-96               257KB        496KB
[   10.218730] kmalloc-64               962KB        995KB
[   10.220155] kmalloc-32              1755KB       1770KB
[   10.221622] kmalloc-16              1597KB       1604KB
[   10.223047] kmalloc-8               1370KB       1392KB
[   10.224774] kmem_cache_node           91KB         94KB
[   10.226223] kmem_cache               142KB        149KB
[   10.227648] Tasks state (memory values in pages):
[   10.228981] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
[   10.231399] [    128]     0   128     8930      954   114688        0         -1000 systemd-udevd
[   10.233952] [    130]     0   130     8765      523   110592        0             0 systemd-udevd
[   10.236312] [    132]     0   132     8765      524   110592        0             0 systemd-udevd
[   10.238702] [    180]     0   180     1162       75    45056        0             0 systemd-detect-
[   10.241295] [    181]     0   181     7725        0   110592        0             0 systemd-journal
[   10.243763] [    185]     0   185     2400        0    81920        0             0 dracut-initqueu
[   10.246177] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),global_oom,task_memcg=/,task=systemd-udevd,pid=132,uid=0
[   10.249123] Out of memory: Kill process 132 (systemd-udevd) score 17 or sacrifice child
[   10.251446] Killed process 132 (systemd-udevd) total-vm:35060kB, anon-rss:400kB, file-rss:4kB, shmem-rss:1692kB
[   11.295270] oom_reaper: unable to reap pid:132 (systemd-udevd)
[   11.296965]   task                        PC stack   pid father
(...snipped...)
[   12.965253] systemd-udevd   R  running task    27168   132    128 0x80100004
[   12.967313] Call Trace:
[   12.968074]  __schedule+0x6c0/0x1a00
[   12.969115]  ? __lock_is_held+0xbc/0x140
[   12.970270]  ? pci_mmcfg_check_reserved+0x120/0x120
[   12.971690]  preempt_schedule_common+0x22/0x60
[   12.973055]  _cond_resched+0x1d/0x30
[   12.974087]  __alloc_pages_nodemask+0x3bd/0x610
[   12.975386]  ? __alloc_pages_slowpath+0x2380/0x2380
[   12.976801]  ? kasan_check_read+0x11/0x20
[   12.978054]  __pmd_alloc+0x36/0x370
[   12.979037]  ? __pud_alloc+0x83/0x120
[   12.980073]  copy_page_range+0x1024/0x1af0
[   12.981183]  ? sched_clock_cpu+0x1b/0x170
[   12.982272]  ? sched_clock+0x9/0x10
[   12.983266]  ? find_held_lock+0x40/0x1e0
[   12.984474]  ? check_flags.part.40+0x420/0x420
[   12.985709]  ? vma_gap_callbacks_rotate+0x5a/0x90
[   12.987059]  ? __pmd_alloc+0x370/0x370
[   12.988112]  ? __vma_link_rb+0x1fc/0x340
[   12.989283]  copy_process.part.56+0x2f0e/0x6c80
[   12.990617]  ? __cleanup_sighand+0x40/0x40
[   12.991724]  ? sched_clock_cpu+0x1b/0x170
[   12.992839]  ? find_held_lock+0x40/0x1e0
[   12.993919]  ? check_flags.part.40+0x420/0x420
[   12.995193]  _do_fork+0x15d/0xb90
[   12.996176]  ? __fd_install+0x16c/0x470
[   12.997216]  ? fork_idle+0x250/0x250
[   12.998252]  ? fd_install+0x47/0x60
[   12.999399]  ? do_pipe2+0x102/0x140
[   13.000389]  ? pci_mmcfg_check_reserved+0x120/0x120
[   13.001735]  ? trace_hardirqs_on_thunk+0x1a/0x1c
[   13.003004]  ? do_syscall_64+0x18/0x3e0
[   13.004050]  ? entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   13.005490]  __x64_sys_clone+0xba/0x140
[   13.006786]  do_syscall_64+0x8f/0x3e0
[   13.007781]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   13.009242] RIP: 0033:0x7f674d010f42
[   13.010293] Code: f7 d8 64 89 04 25 d4 02 00 00 64 4c 8b 04 25 10 00 00 00 31 d2 4d 8d 90 d0 02 00 00 31 f6 bf 11 00 20 01 b8 38 00 00 00 0f 05 <48> 3d 00 f0 ff ff 0f 87 5d 01 00 00 85 c0 41 89 c5 0f 85 67 01 00
[   13.015179] RSP: 002b:00007ffcf9331600 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
[   13.017273] RAX: ffffffffffffffda RBX: 00007ffcf9331600 RCX: 00007f674d010f42
[   13.019208] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
[   13.021216] RBP: 00007ffcf9331640 R08: 00007f674e3ef8c0 R09: 0000000000000084
[   13.023186] R10: 00007f674e3efb90 R11: 0000000000000246 R12: 0000000000000000
[   13.025061] R13: 0000000000000000 R14: 00007ffcf9333d20 R15: 00007ffcf9333920
(...snipped...)
[   13.249697] Showing all locks held in the system:
[   13.251378] 1 lock held by oom_reaper/18:
[   13.252499]  #0: 00000000c8a61e24 (rcu_read_lock){....}, at: debug_show_all_locks+0x5b/0x27e
[   13.254906] 1 lock held by systemd-udevd/128:
[   13.256071]  #0: 00000000e09c1ed1 (&mm->mmap_sem){++++}, at: __do_page_fault+0x23a/0x900
[   13.258336] 2 locks held by systemd-udevd/132:
[   13.259559]  #0: 00000000b4432d13 (&mm->mmap_sem){++++}, at: copy_process.part.56+0x23e5/0x6c80
[   13.261868]  #1: 0000000084913324 (&mm->mmap_sem/1){+.+.}, at: copy_process.part.56+0x2408/0x6c80
[   13.264306] 1 lock held by systemd-detect-/180:
[   13.265584]  #0: 000000001cfadba8 (&mm->mmap_sem){++++}, at: __do_page_fault+0x23a/0x900
[   13.267773] 2 locks held by systemd-journal/189:
[   13.269005]  #0: 000000003687636a (&p->lock){+.+.}, at: seq_read+0x66/0x1030
[   13.270934]  #1: 00000000a4d62cb5 (&mm->mmap_sem){++++}, at: __do_page_fault+0x23a/0x900
[   13.273155] 2 locks held by systemctl/190:
[   13.274390]  #0: 000000000f41a6cc (&p->lock){+.+.}, at: seq_read+0x66/0x1030
[   13.276349]  #1: 00000000a1ed5f2f (&mm->mmap_sem){++++}, at: __do_page_fault+0x23a/0x900
[   13.278527] 
[   13.278976] =============================================
[   13.278976] 

