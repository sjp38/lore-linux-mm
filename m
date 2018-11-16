Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 60D4F6B0A7E
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 11:56:38 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 143so13190110pgc.3
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:56:38 -0800 (PST)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id b131si30440704pga.51.2018.11.16.08.56.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 08:56:36 -0800 (PST)
Subject: Re: [LKP] dd2283f260 [ 97.263072]
 WARNING:at_kernel/locking/lockdep.c:#lock_downgrade
References: <20181115055443.GF18977@shao2-debian>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <d9371abc-60f6-ce37-529f-d097464a1412@linux.alibaba.com>
Date: Fri, 16 Nov 2018 08:56:04 -0800
MIME-Version: 1.0
In-Reply-To: <20181115055443.GF18977@shao2-debian>
Content-Type: multipart/alternative;
 boundary="------------BDFD7754B44347C7A04CEACA"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <rong.a.chen@intel.com>, Waiman Long <longman@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, LKP <lkp@01.org>

This is a multi-part message in MIME format.
--------------BDFD7754B44347C7A04CEACA
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit


> a8dda165ec  vfree: add debug might_sleep()
> dd2283f260  mm: mmap: zap pages with read mmap_sem in munmap
> 5929a1f0ff  Merge tag 'riscv-for-linus-4.20-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/palmer/riscv-linux
> 0bc80e3cb0  Add linux-next specific files for 20181114
> +-----------------------------------------------------+------------+------------+------------+---------------+
> |                                                     | a8dda165ec | dd2283f260 | 5929a1f0ff | next-20181114 |
> +-----------------------------------------------------+------------+------------+------------+---------------+
> | boot_successes                                      | 314        | 178        | 190        | 168           |
> | boot_failures                                       | 393        | 27         | 21         | 40            |
> | WARNING:held_lock_freed                             | 383        | 23         | 17         | 39            |
> | is_freeing_memory#-#,with_a_lock_still_held_there   | 383        | 23         | 17         | 39            |
> | BUG:unable_to_handle_kernel                         | 5          | 2          | 4          | 1             |
> | Oops:#[##]                                          | 9          | 3          | 4          | 1             |
> | EIP:debug_check_no_locks_freed                      | 9          | 3          | 4          | 1             |
> | Kernel_panic-not_syncing:Fatal_exception            | 9          | 3          | 4          | 1             |
> | Mem-Info                                            | 4          | 1          |            |               |
> | invoked_oom-killer:gfp_mask=0x                      | 1          | 1          |            |               |
> | WARNING:at_kernel/locking/lockdep.c:#lock_downgrade | 0          | 6          | 4          | 7             |
> | EIP:lock_downgrade                                  | 0          | 6          | 4          | 7             |
> +-----------------------------------------------------+------------+------------+------------+---------------+
>
> [   96.288009] random: get_random_u32 called from arch_rnd+0x3c/0x70 with crng_init=0
> [   96.359626] input_id (331) used greatest stack depth: 6360 bytes left
> [   96.749228] grep (358) used greatest stack depth: 6336 bytes left
> [   96.921470] network.sh (341) used greatest stack depth: 6212 bytes left
> [   97.262340]
> [   97.262587] =========================
> [   97.263072] WARNING: held lock freed!
> [   97.263536] 4.19.0-06969-gdd2283f #1 Not tainted
> [   97.264110] -------------------------
> [   97.264575] udevd/198 is freeing memory 9c16c930-9c16c99b, with a lock still held there!
> [   97.265542] (ptrval) (&anon_vma->rwsem){....}, at: unlink_anon_vmas+0x14e/0x420
> [   97.266450] 1 lock held by udevd/198:
> [   97.266924]  #0: (ptrval) (&mm->mmap_sem){....}, at: __do_munmap+0x531/0x730

I have not figured out what this is caused by. But, the below warning 
looks more confusing. This might be caused by the below one.

> [   97.267773]
> [   97.267773] stack backtrace:
> [   97.268140] _warn_unseeded_randomness: 113 callbacks suppressed
> [   97.268148] random: get_random_u32 called from copy_process+0x673/0x2d80 with crng_init=0
> [   97.268310] CPU: 1 PID: 198 Comm: udevd Not tainted 4.19.0-06969-gdd2283f #1
> [   97.270901] Call Trace:
> [   97.271232]  dump_stack+0xd6/0x11a
> [   97.271674]  debug_check_no_locks_freed+0x249/0x2c0
> [   97.272311]  kmem_cache_free+0x193/0x6e0
> [   97.272805]  __put_anon_vma+0xd6/0x240
> [   97.273280]  unlink_anon_vmas+0x362/0x420
> [   97.273793]  free_pgtables+0x46/0x190
> [   97.274253]  unmap_region+0x168/0x1b0
> [   97.274711]  __do_munmap+0x558/0x730
> [   97.275164]  __vm_munmap+0x92/0x120
> [   97.275604]  sys_munmap+0x26/0x40
> [   97.276026]  do_int80_syscall_32+0xfe/0x360
> [   97.276545]  entry_INT80_32+0xda/0xda
> [   97.277036] EIP: 0x47f42d61
> [   97.277391] Code: c1 be a2 09 00 8b 89 08 ff ff ff 31 d2 29 c2 65 89 11 83 c8 ff eb d7 90 90 89 da 8b 4c 24 08 8b 5c 24 04 b8 5b 00 00 00 cd 80 <89> d3 3d 01 f0 ff ff 73 01 c3 e8 76 c3 03 00 81 c1 84 a2 09 00 8b
> [   97.279628] EAX: ffffffda EBX: 77f68000 ECX: 00001000 EDX: 47fdcff4
> [   97.280412] ESI: 08080da0 EDI: 00000000 EBP: 00000000 ESP: 7fbf1d08
> [   97.281182] DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b EFLAGS: 00000206
> [   97.376958] ------------[ cut here ]------------
> [   97.377600] downgrading a read lock

I'm confused why it is trying to downgrade a read lock. sys_munmap() 
should just hold write lock before reaching downgrade_write().

But, taking a look at lock_downgrade(), it sounds the lock is set to 
read, then calling require_held_locks(). Is possible there are some race 
conditions?

Cc'ed Waiman Long.

Thanks,
Yang

<https://elixir.bootlin.com/linux/v4.20-rc2/ident/reacquire_held_locks>
> [   97.377622] WARNING: CPU: 0 PID: 198 at kernel/locking/lockdep.c:3556 lock_downgrade+0x20c/0x3a0
> [   97.379416] CPU: 0 PID: 198 Comm: udevd Not tainted 4.19.0-06969-gdd2283f #1
> [   97.380330] EIP: lock_downgrade+0x20c/0x3a0
> [   97.380896] Code: 05 78 7a 95 84 01 c7 04 24 4f 5e b9 83 89 45 e0 83 15 7c 7a 95 84 00 e8 e2 5c f5 ff 83 05 80 7a 95 84 01 83 15 84 7a 95 84 00 <0f> 0b 8b 45 ec 83 05 88 7a 95 84 01 89 45 e8 8b 45 e0 83 15 8c 7a
> [   97.383256] EAX: 00000017 EBX: 9d6adc80 ECX: 00000000 EDX: 000002dc
> [   97.384100] ESI: 00000001 EDI: 8141bb11 EBP: 9c1b5ee8 ESP: 9c1b5ec0
> [   97.384938] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00010046
> [   97.385831] CR0: 80050033 CR2: 77f68000 CR3: 1c11d000 CR4: 00140690
> [   97.386641] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> [   97.387443] DR6: fffe0ff0 DR7: 00000400
> [   97.387980] Call Trace:
> [   97.388333]  downgrade_write+0x3d/0x1b0
> [   97.388865]  __do_munmap+0x531/0x730
> [   97.389406]  __vm_munmap+0x92/0x120
> [   97.389891]  sys_munmap+0x26/0x40
> [   97.390351]  do_int80_syscall_32+0xfe/0x360
> [   97.390923]  entry_INT80_32+0xda/0xda
> [   97.391437] EIP: 0x47f42d61
> [   97.391813] Code: c1 be a2 09 00 8b 89 08 ff ff ff 31 d2 29 c2 65 89 11 83 c8 ff eb d7 90 90 89 da 8b 4c 24 08 8b 5c 24 04 b8 5b 00 00 00 cd 80 <89> d3 3d 01 f0 ff ff 73 01 c3 e8 76 c3 03 00 81 c1 84 a2 09 00 8b
> [   97.394148] EAX: ffffffda EBX: 77f68000 ECX: 00001000 EDX: 47fdcff4
> [   97.394945] ESI: 08080da0 EDI: 00000000 EBP: 00000000 ESP: 7fbf1d08
> [   97.395759] DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b EFLAGS: 00000206
> [   97.396628] ---[ end trace 2d49d562090f3ba6 ]---
> [   97.502082] random: get_random_u32 called from arch_rnd+0x3c/0x70 with crng_init=0
>
>                                                            # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
> git bisect start ccda4af0f4b92f7b4c308d3acc262f4a7e3affad v4.19 --
> git bisect  bad ac435075892e3e651c667b4a9f2267cf3ef1d5a2  # 01:46  B      4     1    3   3  Merge tag 'csky-for-linus-4.20' of https://github.com/c-sky/csky-linux
> git bisect good 01aa9d518eae8a4d75cd3049defc6ed0b6d0a658  # 03:05  G     42     0    6   6  Merge tag 'docs-4.20' of git://git.lwn.net/linux
> git bisect good 26873acacbdbb4e4b444f5dd28dcc4853f0e8ba2  # 03:30  G     44     0    4   4  Merge tag 'driver-core-4.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core
> git bisect good a45dcff7489f7cb21a3a8e967a90ea41b31c1559  # 03:49  G     44     0    8   8  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc
> git bisect  bad 5ecf3e110c32c5756351eed067cdf6a91c308e62  # 04:07  B     17     1    1   1  Merge tag 'linux-watchdog-4.20-rc1' of git://www.linux-watchdog.org/linux-watchdog
> git bisect  bad b59dfdaef173677b0b7e10f375226c0a1114fd20  # 04:35  B     20     1    5   5  i2c-hid: properly terminate i2c_hid_dmi_desc_override_table[] array
> git bisect good 4904008165c8a1c48602b8316139691b8c735e6e  # 05:48  G    200     0   24  24  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> git bisect  bad 345671ea0f9258f410eb057b9ced9cefbbe5dc78  # 06:13  B     31     1    5   5  Merge branch 'akpm' (patches from Andrew)
> git bisect good 4b85afbdacd290c7a22c96df40a6433fdcacb509  # 06:53  G    205     0  101 101  mm: zero-seek shrinkers
> git bisect  bad 85a06835f6f1ba79f0f00838ccd5ad840dd1eafb  # 07:24  B     61     3   34  34  mm: mremap: downgrade mmap_sem to read when shrinking
> git bisect  bad 85cfb245060e45640fa3447f8b0bad5e8bd3bdaf  # 07:43  B     20     1    2   2  memcg: remove memcg_kmem_skip_account
> git bisect  bad dd2283f2605e3b3e9c61bcae844b34f2afa4813f  # 08:02  B     15     1    0   0  mm: mmap: zap pages with read mmap_sem in munmap
> git bisect good dedf2c73b80b4566dfcae8ebe9ed46a38b63a1f9  # 08:36  G    196     0   33  33  mm/mempolicy.c: use match_string() helper to simplify the code
> git bisect good 3ca4ea3a7a78a243ee9edf71a2736bc8fb26d70f  # 10:40  G    197     0   31  31  mm/vmalloc.c: improve vfree() kerneldoc
> git bisect good a8dda165ec34fac2b4119654330150e2c896e531  # 11:28  G    202     0  114 115  vfree: add debug might_sleep()
> # first bad commit: [dd2283f2605e3b3e9c61bcae844b34f2afa4813f] mm: mmap: zap pages with read mmap_sem in munmap
> git bisect good a8dda165ec34fac2b4119654330150e2c896e531  # 12:17  G    585     0  283 399  vfree: add debug might_sleep()
> # extra tests with debug options
> git bisect  bad dd2283f2605e3b3e9c61bcae844b34f2afa4813f  # 12:38  B     14     1    4   4  mm: mmap: zap pages with read mmap_sem in munmap
> # extra tests on HEAD of linux-devel/devel-hourly-2018111421
> git bisect  bad ead84f4ee6640e1bda88302f402bf5f2e0cf78ec  # 12:38  B      5     3    0   5  0day head guard for 'devel-hourly-2018111421'
> # extra tests on tree/branch linus/master
> git bisect  bad 5929a1f0ff30d04ccf4b0f9c648e7aa8bc816bbd  # 12:59  B     36     1    8   8  Merge tag 'riscv-for-linus-4.20-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/palmer/riscv-linux
> # extra tests on tree/branch linux-next/master
> git bisect  bad 0bc80e3cb0c14878ae0a7779d46f1192221f080e  # 13:19  B     57     3   14  14  Add linux-next specific files for 20181114
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/lkp                          Intel Corporation


--------------BDFD7754B44347C7A04CEACA
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;
      charset=windows-1252">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <br>
    <blockquote type="cite"
      cite="mid:20181115055443.GF18977@shao2-debian">
      <pre wrap="">
a8dda165ec  vfree: add debug might_sleep()
dd2283f260  mm: mmap: zap pages with read mmap_sem in munmap
5929a1f0ff  Merge tag 'riscv-for-linus-4.20-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/palmer/riscv-linux
0bc80e3cb0  Add linux-next specific files for 20181114
+-----------------------------------------------------+------------+------------+------------+---------------+
|                                                     | a8dda165ec | dd2283f260 | 5929a1f0ff | next-20181114 |
+-----------------------------------------------------+------------+------------+------------+---------------+
| boot_successes                                      | 314        | 178        | 190        | 168           |
| boot_failures                                       | 393        | 27         | 21         | 40            |
| WARNING:held_lock_freed                             | 383        | 23         | 17         | 39            |
| is_freeing_memory#-#,with_a_lock_still_held_there   | 383        | 23         | 17         | 39            |
| BUG:unable_to_handle_kernel                         | 5          | 2          | 4          | 1             |
| Oops:#[##]                                          | 9          | 3          | 4          | 1             |
| EIP:debug_check_no_locks_freed                      | 9          | 3          | 4          | 1             |
| Kernel_panic-not_syncing:Fatal_exception            | 9          | 3          | 4          | 1             |
| Mem-Info                                            | 4          | 1          |            |               |
| invoked_oom-killer:gfp_mask=0x                      | 1          | 1          |            |               |
| WARNING:at_kernel/locking/lockdep.c:#lock_downgrade | 0          | 6          | 4          | 7             |
| EIP:lock_downgrade                                  | 0          | 6          | 4          | 7             |
+-----------------------------------------------------+------------+------------+------------+---------------+

[   96.288009] random: get_random_u32 called from arch_rnd+0x3c/0x70 with crng_init=0
[   96.359626] input_id (331) used greatest stack depth: 6360 bytes left
[   96.749228] grep (358) used greatest stack depth: 6336 bytes left
[   96.921470] network.sh (341) used greatest stack depth: 6212 bytes left
[   97.262340] 
[   97.262587] =========================
[   97.263072] WARNING: held lock freed!
[   97.263536] 4.19.0-06969-gdd2283f #1 Not tainted
[   97.264110] -------------------------
[   97.264575] udevd/198 is freeing memory 9c16c930-9c16c99b, with a lock still held there!
[   97.265542] (ptrval) (&amp;anon_vma-&gt;rwsem){....}, at: unlink_anon_vmas+0x14e/0x420
[   97.266450] 1 lock held by udevd/198:
[   97.266924]  #0: (ptrval) (&amp;mm-&gt;mmap_sem){....}, at: __do_munmap+0x531/0x730</pre>
    </blockquote>
    <br>
    I have not figured out what this is caused by. But, the below
    warning looks more confusing. This might be caused by the below one.<br>
    <br>
    <blockquote type="cite"
      cite="mid:20181115055443.GF18977@shao2-debian">
      <pre wrap="">
[   97.267773] 
[   97.267773] stack backtrace:
[   97.268140] _warn_unseeded_randomness: 113 callbacks suppressed
[   97.268148] random: get_random_u32 called from copy_process+0x673/0x2d80 with crng_init=0
[   97.268310] CPU: 1 PID: 198 Comm: udevd Not tainted 4.19.0-06969-gdd2283f #1
[   97.270901] Call Trace:
[   97.271232]  dump_stack+0xd6/0x11a
[   97.271674]  debug_check_no_locks_freed+0x249/0x2c0
[   97.272311]  kmem_cache_free+0x193/0x6e0
[   97.272805]  __put_anon_vma+0xd6/0x240
[   97.273280]  unlink_anon_vmas+0x362/0x420
[   97.273793]  free_pgtables+0x46/0x190
[   97.274253]  unmap_region+0x168/0x1b0
[   97.274711]  __do_munmap+0x558/0x730
[   97.275164]  __vm_munmap+0x92/0x120
[   97.275604]  sys_munmap+0x26/0x40
[   97.276026]  do_int80_syscall_32+0xfe/0x360
[   97.276545]  entry_INT80_32+0xda/0xda
[   97.277036] EIP: 0x47f42d61
[   97.277391] Code: c1 be a2 09 00 8b 89 08 ff ff ff 31 d2 29 c2 65 89 11 83 c8 ff eb d7 90 90 89 da 8b 4c 24 08 8b 5c 24 04 b8 5b 00 00 00 cd 80 &lt;89&gt; d3 3d 01 f0 ff ff 73 01 c3 e8 76 c3 03 00 81 c1 84 a2 09 00 8b
[   97.279628] EAX: ffffffda EBX: 77f68000 ECX: 00001000 EDX: 47fdcff4
[   97.280412] ESI: 08080da0 EDI: 00000000 EBP: 00000000 ESP: 7fbf1d08
[   97.281182] DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b EFLAGS: 00000206
[   97.376958] ------------[ cut here ]------------
[   97.377600] downgrading a read lock</pre>
    </blockquote>
    <br>
    I'm confused why it is trying to downgrade a read lock. sys_munmap()
    should just hold write lock before reaching downgrade_write().<br>
    <br>
    But, taking a look at lock_downgrade(), it sounds the lock is set to
    read, then calling require_held_locks(). Is possible there are some
    race conditions?<br>
    <br>
    Cc'ed Waiman Long.<br>
    <br>
    Thanks,<br>
    Yang<br>
    <br>
    <span class="nf" style="box-sizing: inherit; color: rgb(0, 102,
      187);"><a
href="https://elixir.bootlin.com/linux/v4.20-rc2/ident/reacquire_held_locks"
        style="box-sizing: inherit; background-color: rgb(244, 246,
        255); color: inherit; text-decoration: none; font-weight: 700;
        box-shadow: rgb(244, 246, 255) 0px 0px 0px 1px; border-radius:
        0.2em;"></a></span>
    <blockquote type="cite"
      cite="mid:20181115055443.GF18977@shao2-debian">
      <pre wrap="">
[   97.377622] WARNING: CPU: 0 PID: 198 at kernel/locking/lockdep.c:3556 lock_downgrade+0x20c/0x3a0
[   97.379416] CPU: 0 PID: 198 Comm: udevd Not tainted 4.19.0-06969-gdd2283f #1
[   97.380330] EIP: lock_downgrade+0x20c/0x3a0
[   97.380896] Code: 05 78 7a 95 84 01 c7 04 24 4f 5e b9 83 89 45 e0 83 15 7c 7a 95 84 00 e8 e2 5c f5 ff 83 05 80 7a 95 84 01 83 15 84 7a 95 84 00 &lt;0f&gt; 0b 8b 45 ec 83 05 88 7a 95 84 01 89 45 e8 8b 45 e0 83 15 8c 7a
[   97.383256] EAX: 00000017 EBX: 9d6adc80 ECX: 00000000 EDX: 000002dc
[   97.384100] ESI: 00000001 EDI: 8141bb11 EBP: 9c1b5ee8 ESP: 9c1b5ec0
[   97.384938] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00010046
[   97.385831] CR0: 80050033 CR2: 77f68000 CR3: 1c11d000 CR4: 00140690
[   97.386641] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[   97.387443] DR6: fffe0ff0 DR7: 00000400
[   97.387980] Call Trace:
[   97.388333]  downgrade_write+0x3d/0x1b0
[   97.388865]  __do_munmap+0x531/0x730
[   97.389406]  __vm_munmap+0x92/0x120
[   97.389891]  sys_munmap+0x26/0x40
[   97.390351]  do_int80_syscall_32+0xfe/0x360
[   97.390923]  entry_INT80_32+0xda/0xda
[   97.391437] EIP: 0x47f42d61
[   97.391813] Code: c1 be a2 09 00 8b 89 08 ff ff ff 31 d2 29 c2 65 89 11 83 c8 ff eb d7 90 90 89 da 8b 4c 24 08 8b 5c 24 04 b8 5b 00 00 00 cd 80 &lt;89&gt; d3 3d 01 f0 ff ff 73 01 c3 e8 76 c3 03 00 81 c1 84 a2 09 00 8b
[   97.394148] EAX: ffffffda EBX: 77f68000 ECX: 00001000 EDX: 47fdcff4
[   97.394945] ESI: 08080da0 EDI: 00000000 EBP: 00000000 ESP: 7fbf1d08
[   97.395759] DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b EFLAGS: 00000206
[   97.396628] ---[ end trace 2d49d562090f3ba6 ]---
[   97.502082] random: get_random_u32 called from arch_rnd+0x3c/0x70 with crng_init=0

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start ccda4af0f4b92f7b4c308d3acc262f4a7e3affad v4.19 --
git bisect  bad ac435075892e3e651c667b4a9f2267cf3ef1d5a2  # 01:46  B      4     1    3   3  Merge tag 'csky-for-linus-4.20' of <a class="moz-txt-link-freetext" href="https://github.com/c-sky/csky-linux">https://github.com/c-sky/csky-linux</a>
git bisect good 01aa9d518eae8a4d75cd3049defc6ed0b6d0a658  # 03:05  G     42     0    6   6  Merge tag 'docs-4.20' of git://git.lwn.net/linux
git bisect good 26873acacbdbb4e4b444f5dd28dcc4853f0e8ba2  # 03:30  G     44     0    4   4  Merge tag 'driver-core-4.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core
git bisect good a45dcff7489f7cb21a3a8e967a90ea41b31c1559  # 03:49  G     44     0    8   8  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc
git bisect  bad 5ecf3e110c32c5756351eed067cdf6a91c308e62  # 04:07  B     17     1    1   1  Merge tag 'linux-watchdog-4.20-rc1' of git://www.linux-watchdog.org/linux-watchdog
git bisect  bad b59dfdaef173677b0b7e10f375226c0a1114fd20  # 04:35  B     20     1    5   5  i2c-hid: properly terminate i2c_hid_dmi_desc_override_table[] array
git bisect good 4904008165c8a1c48602b8316139691b8c735e6e  # 05:48  G    200     0   24  24  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect  bad 345671ea0f9258f410eb057b9ced9cefbbe5dc78  # 06:13  B     31     1    5   5  Merge branch 'akpm' (patches from Andrew)
git bisect good 4b85afbdacd290c7a22c96df40a6433fdcacb509  # 06:53  G    205     0  101 101  mm: zero-seek shrinkers
git bisect  bad 85a06835f6f1ba79f0f00838ccd5ad840dd1eafb  # 07:24  B     61     3   34  34  mm: mremap: downgrade mmap_sem to read when shrinking
git bisect  bad 85cfb245060e45640fa3447f8b0bad5e8bd3bdaf  # 07:43  B     20     1    2   2  memcg: remove memcg_kmem_skip_account
git bisect  bad dd2283f2605e3b3e9c61bcae844b34f2afa4813f  # 08:02  B     15     1    0   0  mm: mmap: zap pages with read mmap_sem in munmap
git bisect good dedf2c73b80b4566dfcae8ebe9ed46a38b63a1f9  # 08:36  G    196     0   33  33  mm/mempolicy.c: use match_string() helper to simplify the code
git bisect good 3ca4ea3a7a78a243ee9edf71a2736bc8fb26d70f  # 10:40  G    197     0   31  31  mm/vmalloc.c: improve vfree() kerneldoc
git bisect good a8dda165ec34fac2b4119654330150e2c896e531  # 11:28  G    202     0  114 115  vfree: add debug might_sleep()
# first bad commit: [dd2283f2605e3b3e9c61bcae844b34f2afa4813f] mm: mmap: zap pages with read mmap_sem in munmap
git bisect good a8dda165ec34fac2b4119654330150e2c896e531  # 12:17  G    585     0  283 399  vfree: add debug might_sleep()
# extra tests with debug options
git bisect  bad dd2283f2605e3b3e9c61bcae844b34f2afa4813f  # 12:38  B     14     1    4   4  mm: mmap: zap pages with read mmap_sem in munmap
# extra tests on HEAD of linux-devel/devel-hourly-2018111421
git bisect  bad ead84f4ee6640e1bda88302f402bf5f2e0cf78ec  # 12:38  B      5     3    0   5  0day head guard for 'devel-hourly-2018111421'
# extra tests on tree/branch linus/master
git bisect  bad 5929a1f0ff30d04ccf4b0f9c648e7aa8bc816bbd  # 12:59  B     36     1    8   8  Merge tag 'riscv-for-linus-4.20-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/palmer/riscv-linux
# extra tests on tree/branch linux-next/master
git bisect  bad 0bc80e3cb0c14878ae0a7779d46f1192221f080e  # 13:19  B     57     3   14  14  Add linux-next specific files for 20181114

---
0-DAY kernel test infrastructure                Open Source Technology Center
<a class="moz-txt-link-freetext" href="https://lists.01.org/pipermail/lkp">https://lists.01.org/pipermail/lkp</a>                          Intel Corporation
</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------BDFD7754B44347C7A04CEACA--
