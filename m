Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0E46B04E4
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:42:22 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t75so812071pgb.0
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 11:42:22 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 72si49138pla.129.2017.07.11.11.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 11:42:21 -0700 (PDT)
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <ff6cb2b9-b930-afad-1a1f-1c437eced3cf@nvidia.com>
 <20170711182922.GC5347@redhat.com>
From: Evgeny Baskakov <ebaskakov@nvidia.com>
Message-ID: <7a4478cb-7eb6-2546-e707-1b0f18e3acd4@nvidia.com>
Date: Tue, 11 Jul 2017 11:42:20 -0700
MIME-Version: 1.0
In-Reply-To: <20170711182922.GC5347@redhat.com>
Content-Type: multipart/mixed;
	boundary="------------205ABB212241F6871FD3CED7"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

--------------205ABB212241F6871FD3CED7
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit

On 7/11/17 11:29 AM, Jerome Glisse wrote:
> Can you test if attached patch helps ? I am having trouble reproducing 
> this
> from inside a vm.
>
> My theory is that 2 concurrent CPU page fault happens. First one manage to
> start the migration back to system memory but second one see the migration
> special entry and call migration_entry_wait() which increase page refcount
> and this happen before first one check page refcount are ok for migration.
>
> For regular migration such scenario is ok as the migration bails out and
> because page is CPU accessible there is no need to kick again the migration
> for other thread that CPU fault to migrate.
>
> I am looking into how i can change migration_entry_wait() not to refcount
> pages. Let me know if the attached patch helps.
>
> Thank you
> Jerome

Hi Jerome,

Thanks for the update.

Unfortunately, the patch does not help. I just applied it and recompiled 
the kernel. Please find attached a new kernel log and an app log.

-- 
Evgeny Baskakov
NVIDIA


--------------205ABB212241F6871FD3CED7
Content-Type: text/plain; charset="UTF-8"; x-mac-type=0; x-mac-creator=0;
	name="test.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="test.log"

sanity_rmem004_repeated_faults_threaded$ ./run.sh
&&& 2 migrate threads, 2 read threads: STARTING
iteration 0
iteration 1
iteration 2
iteration 3
iteration 4
iteration 5
iteration 6
iteration 7
iteration 8
(EE:84) hmm_buffer_mirror_read error -1
iteration 9
iteration 10
iteration 11
iteration 12
iteration 13
iteration 14
iteration 15
iteration 16
iteration 17
(EE:84) hmm_buffer_mirror_read error -1
iteration 18
iteration 19
iteration 20
iteration 21
(EE:84) hmm_buffer_mirror_read error -1
iteration 22
iteration 23
(EE:84) hmm_buffer_mirror_read error -1
iteration 24
iteration 25
iteration 26
iteration 27
iteration 28
iteration 29
iteration 30
iteration 31
iteration 32
iteration 33
iteration 34
iteration 35
iteration 36
iteration 37
iteration 38
iteration 39
iteration 40
iteration 41
iteration 42
iteration 43
iteration 44
iteration 45
iteration 46
iteration 47
iteration 48
iteration 49
iteration 50
iteration 51
(EE:84) hmm_buffer_mirror_read error -1
iteration 52
iteration 53
iteration 54
iteration 55
iteration 56
iteration 57
iteration 58
iteration 59
iteration 60
iteration 61
iteration 62
iteration 63
iteration 64
iteration 65
iteration 66
iteration 67
iteration 68
iteration 69
iteration 70
iteration 71
iteration 72
iteration 73
iteration 74
iteration 75
iteration 76
iteration 77
(EE:84) hmm_buffer_mirror_read error -1
iteration 78
iteration 79
iteration 80
iteration 81
iteration 82
iteration 83
(EE:84) hmm_buffer_mirror_read error -1
iteration 84
iteration 85
iteration 86
iteration 87
iteration 88
iteration 89
(EE:84) hmm_buffer_mirror_read error -1
iteration 90
iteration 91
(EE:84) hmm_buffer_mirror_read error -1
iteration 92
iteration 93
iteration 94
iteration 95
iteration 96
iteration 97
iteration 98
iteration 99
&&& 2 migrate threads, 2 read threads: PASSED
&&& 2 migrate threads, 3 read threads: STARTING
iteration 0
iteration 1
iteration 2
(EE:84) hmm_buffer_mirror_read error -1
iteration 3
iteration 4
iteration 5
iteration 6
iteration 7
iteration 8
iteration 9
iteration 10
iteration 11
iteration 12
iteration 13
iteration 14
iteration 15
iteration 16
iteration 17
iteration 18
iteration 19
iteration 20
iteration 21
iteration 22
iteration 23
iteration 24
iteration 25
iteration 26
iteration 27
iteration 28
iteration 29
(EE:84) hmm_buffer_mirror_read error -1
iteration 30
iteration 31
iteration 32
iteration 33
iteration 34
iteration 35
iteration 36
iteration 37
iteration 38
iteration 39
iteration 40
iteration 41
iteration 42
iteration 43
iteration 44
iteration 45
iteration 46
iteration 47
iteration 48
iteration 49
iteration 50
iteration 51
iteration 52
iteration 53
iteration 54
iteration 55
iteration 56
iteration 57
iteration 58
iteration 59
iteration 60
iteration 61
iteration 62
iteration 63
iteration 64
iteration 65
iteration 66
iteration 67
iteration 68
iteration 69
iteration 70
iteration 71
iteration 72
iteration 73
iteration 74
iteration 75
iteration 76
iteration 77
iteration 78
iteration 79
iteration 80
iteration 81
iteration 82
iteration 83
iteration 84
(EE:84) hmm_buffer_mirror_read error -1
iteration 85
iteration 86
(EE:84) hmm_buffer_mirror_read error -1
iteration 87
iteration 88
iteration 89
iteration 90
iteration 91
(EE:84) hmm_buffer_mirror_read error -1
iteration 92
iteration 93
iteration 94
iteration 95
(EE:84) hmm_buffer_mirror_read error -1
iteration 96
iteration 97
iteration 98
iteration 99
&&& 2 migrate threads, 3 read threads: PASSED
&&& 2 migrate threads, 4 read threads: STARTING
iteration 0
iteration 1
iteration 2
iteration 3
iteration 4
iteration 5
iteration 6
iteration 7
iteration 8
iteration 9
iteration 10
iteration 11
iteration 12
iteration 13
iteration 14
iteration 15
iteration 16
iteration 17
iteration 18
iteration 19
iteration 20
iteration 21
iteration 22
iteration 23
iteration 24
iteration 25
iteration 26
iteration 27
iteration 28
iteration 29
iteration 30
iteration 31
iteration 32
iteration 33
(EE:84) hmm_buffer_mirror_read error -1
iteration 34
iteration 35
iteration 36
iteration 37
iteration 38
iteration 39
iteration 40
iteration 41
iteration 42
iteration 43
iteration 44
iteration 45
iteration 46
iteration 47
iteration 48
iteration 49
iteration 50
iteration 51
iteration 52
iteration 53
iteration 54
iteration 55
(EE:84) hmm_buffer_mirror_read error -1
iteration 56
iteration 57
iteration 58
iteration 59
iteration 60
iteration 61
iteration 62
iteration 63
iteration 64
iteration 65
iteration 66
iteration 67
iteration 68
iteration 69
iteration 70
iteration 71
iteration 72
iteration 73
iteration 74
iteration 75
iteration 76
iteration 77
iteration 78
iteration 79
iteration 80
iteration 81
iteration 82
iteration 83
iteration 84
iteration 85
iteration 86
iteration 87
iteration 88
iteration 89
iteration 90
iteration 91
iteration 92
iteration 93
iteration 94
iteration 95
iteration 96
iteration 97
iteration 98
iteration 99
&&& 2 migrate threads, 4 read threads: PASSED
&&& 3 migrate threads, 2 read threads: STARTING
iteration 0
iteration 1
iteration 2
iteration 3
iteration 4
iteration 5
iteration 6
iteration 7
iteration 8
iteration 9
iteration 10
iteration 11
iteration 12
(EE:84) hmm_buffer_mirror_read error -1
iteration 13
iteration 14
iteration 15
iteration 16
iteration 17
iteration 18
(EE:84) hmm_buffer_mirror_read error -1
iteration 19
(EE:84) hmm_buffer_mirror_read error -1
iteration 20
iteration 21
iteration 22

--------------205ABB212241F6871FD3CED7
Content-Type: text/plain; charset="UTF-8"; x-mac-type=0; x-mac-creator=0;
	name="kernel.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="kernel.log"

[   52.928642] hmm_dmirror loaded THIS IS A DANGEROUS MODULE !!!
[   64.367872] DEVICE PAGE 449938 449938 (0)
[   74.757473] DEVICE PAGE 923480 923480 (0)
[   85.617138] DEVICE PAGE 1460301 1460301 (0)
[  118.816301] sysrq: SysRq : Show Blocked State
[  118.816379]   task                        PC stack   pid father
[  118.816382] rcu_sched       D15024     8      2 0x00000000
[  118.816391] Call Trace:
[  118.816398]  __schedule+0x20b/0x6c0
[  118.816400]  schedule+0x36/0x80
[  118.816406]  rcu_gp_kthread+0x74/0x770
[  118.816411]  kthread+0x109/0x140
[  118.816415]  ? force_qs_rnp+0x180/0x180
[  118.816418]  ? kthread_park+0x60/0x60
[  118.816421]  ret_from_fork+0x22/0x30
[  118.816424] rcu_bh          D15424     9      2 0x00000000
[  118.816430] Call Trace:
[  118.816432]  __schedule+0x20b/0x6c0
[  118.816434]  schedule+0x36/0x80
[  118.816438]  rcu_gp_kthread+0x74/0x770
[  118.816441]  kthread+0x109/0x140
[  118.816445]  ? force_qs_rnp+0x180/0x180
[  118.816448]  ? kthread_park+0x60/0x60
[  118.816451]  ret_from_fork+0x22/0x30
[  118.816479] sanity_rmem004  D13904  3898   3897 0x00000000
[  118.816486] Call Trace:
[  118.816488]  __schedule+0x20b/0x6c0
[  118.816490]  schedule+0x36/0x80
[  118.816493]  rwsem_down_write_failed_killable+0x1f5/0x3f0
[  118.816497]  ? account_entity_enqueue+0x9d/0xc0
[  118.816501]  call_rwsem_down_write_failed_killable+0x17/0x30
[  118.816506]  ? selinux_file_mprotect+0x140/0x140
[  118.816509]  down_write_killable+0x2d/0x50
[  118.816513]  vm_mmap_pgoff+0x78/0xf0
[  118.816518]  SyS_mmap_pgoff+0x103/0x270
[  118.816522]  SyS_mmap+0x22/0x30
[  118.816525]  entry_SYSCALL_64_fastpath+0x13/0x94
[  118.816527] RIP: 0033:0x7f42b69a187a
[  118.816529] RSP: 002b:00007fff2b4cdb48 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
[  118.816532] RAX: ffffffffffffffda RBX: 00007f42b4cc1700 RCX: 00007f42b69a187a
[  118.816533] RDX: 0000000000000003 RSI: 0000000000801000 RDI: 0000000000000000
[  118.816534] RBP: 00007fff2b4cdba0 R08: 00000000ffffffff R09: 0000000000000000
[  118.816536] R10: 0000000000020022 R11: 0000000000000246 R12: 0000000000000000
[  118.816537] R13: 0000000000000000 R14: 00007f42b4cc19c0 R15: 00007f42b4cc1700
[  118.816539] sanity_rmem004  D13640  5509   3897 0x00000000
[  118.816545] Call Trace:
[  118.816547]  __schedule+0x20b/0x6c0
[  118.816549]  schedule+0x36/0x80
[  118.816552]  rwsem_down_read_failed+0x112/0x180
[  118.816555]  call_rwsem_down_read_failed+0x18/0x30
[  118.816558]  down_read+0x20/0x40
[  118.816563]  dummy_migrate.isra.10+0x43/0x110 [hmm_dmirror]
[  118.816571]  dummy_fops_unlocked_ioctl+0x1e8/0x330 [hmm_dmirror]
[  118.816573]  ? _cond_resched+0x19/0x30
[  118.816577]  ? selinux_file_ioctl+0x114/0x1e0
[  118.816581]  do_vfs_ioctl+0x96/0x5a0
[  118.816584]  SyS_ioctl+0x79/0x90
[  118.816587]  entry_SYSCALL_64_fastpath+0x13/0x94
[  118.816588] RIP: 0033:0x7f42b699e1e7
[  118.816590] RSP: 002b:00007f42b5cc2d78 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[  118.816592] RAX: ffffffffffffffda RBX: 00007f42b5cc3700 RCX: 00007f42b699e1e7
[  118.816593] RDX: 00007f42b5cc2e00 RSI: 00000000c0104802 RDI: 0000000000000003
[  118.816594] RBP: 00007fff2b4cdba0 R08: 00007f42b5cc3700 R09: 00007f42b5cc3700
[  118.816595] R10: 00007f42b5cc39d0 R11: 0000000000000246 R12: 0000000000000000
[  118.816597] R13: 0000000000000000 R14: 00007f42b5cc39c0 R15: 00007f42b5cc3700
[  118.816599] sanity_rmem004  D13696  5510   3897 0x00000000
[  118.816605] Call Trace:
[  118.816607]  __schedule+0x20b/0x6c0
[  118.816609]  schedule+0x36/0x80
[  118.816613]  io_schedule+0x16/0x40
[  118.816618]  __lock_page+0xf2/0x130
[  118.816622]  ? page_cache_tree_insert+0x90/0x90
[  118.816625]  migrate_vma+0x48a/0xee0
[  118.816629]  dummy_migrate.isra.10+0xd9/0x110 [hmm_dmirror]
[  118.816638]  dummy_fops_unlocked_ioctl+0x1e8/0x330 [hmm_dmirror]
[  118.816640]  ? _cond_resched+0x19/0x30
[  118.816643]  ? selinux_file_ioctl+0x114/0x1e0
[  118.816646]  do_vfs_ioctl+0x96/0x5a0
[  118.816649]  SyS_ioctl+0x79/0x90
[  118.816652]  entry_SYSCALL_64_fastpath+0x13/0x94
[  118.816654] RIP: 0033:0x7f42b699e1e7
[  118.816655] RSP: 002b:00007f42b64c3d78 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[  118.816657] RAX: ffffffffffffffda RBX: 00007f42b64c4700 RCX: 00007f42b699e1e7
[  118.816658] RDX: 00007f42b64c3df0 RSI: 00000000c0104802 RDI: 0000000000000003
[  118.816659] RBP: 00007fff2b4cdba0 R08: 0000000000000000 R09: 00007f42b64c4700
[  118.816660] R10: 00007f42b64c49d0 R11: 0000000000000246 R12: 0000000000000000
[  118.816661] R13: 0000000000000000 R14: 00007f42b64c49c0 R15: 00007f42b64c4700
[  118.816663] sanity_rmem004  D13696  5511   3897 0x00000000
[  118.816670] Call Trace:
[  118.816672]  __schedule+0x20b/0x6c0
[  118.816674]  schedule+0x36/0x80
[  118.816677]  io_schedule+0x16/0x40
[  118.816681]  __lock_page+0xf2/0x130
[  118.816684]  ? page_cache_tree_insert+0x90/0x90
[  118.816687]  migrate_vma+0x48a/0xee0
[  118.816691]  dummy_migrate.isra.10+0xd9/0x110 [hmm_dmirror]
[  118.816699]  dummy_fops_unlocked_ioctl+0x1e8/0x330 [hmm_dmirror]
[  118.816701]  ? _cond_resched+0x19/0x30
[  118.816704]  ? selinux_file_ioctl+0x114/0x1e0
[  118.816707]  do_vfs_ioctl+0x96/0x5a0
[  118.816710]  SyS_ioctl+0x79/0x90
[  118.816713]  entry_SYSCALL_64_fastpath+0x13/0x94
[  118.816715] RIP: 0033:0x7f42b699e1e7
[  118.816716] RSP: 002b:00007f42b54c1d78 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[  118.816718] RAX: ffffffffffffffda RBX: 00007f42b54c2700 RCX: 00007f42b699e1e7
[  118.816719] RDX: 00007f42b54c1df0 RSI: 00000000c0104802 RDI: 0000000000000003
[  118.816720] RBP: 00007fff2b4cdba0 R08: 0000000000000000 R09: 00007f42b54c2700
[  118.816721] R10: 00007f42b54c29d0 R11: 0000000000000246 R12: 0000000000000000
[  118.816722] R13: 0000000000000000 R14: 00007f42b54c29c0 R15: 00007f42b54c2700
[  118.816724] sanity_rmem004  D14624  5512   3897 0x00000000
[  118.816730] Call Trace:
[  118.816732]  __schedule+0x20b/0x6c0
[  118.816734]  schedule+0x36/0x80
[  118.816737]  rwsem_down_read_failed+0x112/0x180
[  118.816740]  call_rwsem_down_read_failed+0x18/0x30
[  118.816742]  down_read+0x20/0x40
[  118.816745]  dummy_fault+0x48/0x1f0 [hmm_dmirror]
[  118.816750]  ? __kernel_map_pages+0x70/0xe0
[  118.816754]  ? get_page_from_freelist+0x655/0xb40
[  118.816757]  ? __alloc_pages_nodemask+0x11b/0x240
[  118.816761]  ? dummy_pt_walk+0x209/0x2f0 [hmm_dmirror]
[  118.816764]  ? dummy_update+0x60/0x60 [hmm_dmirror]
[  118.816767]  dummy_fops_unlocked_ioctl+0x12c/0x330 [hmm_dmirror]
[  118.816770]  do_vfs_ioctl+0x96/0x5a0
[  118.816773]  SyS_ioctl+0x79/0x90
[  118.816776]  entry_SYSCALL_64_fastpath+0x13/0x94
[  118.816777] RIP: 0033:0x7f42b699e1e7
[  118.816778] RSP: 002b:00007f42b4cc0c38 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[  118.816780] RAX: ffffffffffffffda RBX: 00007f42b4cc1700 RCX: 00007f42b699e1e7
[  118.816781] RDX: 00007f42b4cc0cd0 RSI: 00000000c0284800 RDI: 0000000000000003
[  118.816782] RBP: 00007fff2b4cdba0 R08: 00007f42b4cc0ef0 R09: 00007f42b4cc1700
[  118.816784] R10: 00007fff2b4cdc60 R11: 0000000000000246 R12: 0000000000000000
[  118.816785] R13: 0000000000000000 R14: 00007f42b4cc19c0 R15: 00007f42b4cc1700

--------------205ABB212241F6871FD3CED7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
