Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id E8DD66B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 08:10:10 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so3886625wib.17
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 05:10:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s20si11559893wiv.102.2014.07.24.05.10.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 05:10:04 -0700 (PDT)
Date: Thu, 24 Jul 2014 14:09:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Bug 80881] New: Memory cgroup OOM leads to BUG: unable to
 handle kernel paging request at ffffffffffffffd8
Message-ID: <20140724120959.GC14578@dhcp22.suse.cz>
References: <bug-80881-27@https.bugzilla.kernel.org/>
 <20140722130741.ca2f6c24d06fffc7d7549e95@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140722130741.ca2f6c24d06fffc7d7549e95@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Paul Furtado <paulfurtado91@gmail.com>

On Tue 22-07-14 13:07:41, Andrew Morton wrote:
[...]
> > The full log is attached, but here is the part I believe is relevant from the
> > 3.16.0-rc5 error:
> > [162005.262545] memory: usage 131072kB, limit 131072kB, failcnt 1314
> > [162005.262550] memory+swap: usage 0kB, limit 18014398509481983kB, failcnt 0
> > [162005.262554] kmem: usage 0kB, limit 18014398509481983kB, failcnt 0
> > [162005.262558] Memory cgroup stats for
> > /mesos/c206ce2a-9f11-4340-a3c9-c59b405690a7: cache:8KB rss:131064KB
> > rss_huge:0KB mapped_file:0KB writeback:0KB inactive_anon:0KB
> > active_anon:131064KB inactive_file:0KB active_file:0KB unevictable:0KB
> > [162005.262581] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents
> > oom_score_adj name
> > [162005.262602] [ 3002]     0  3002   544153    22244     151        0         
> >    0 java7
> > [162005.262609] [ 3061]     0  3061   424397    20423      88        0         
> >    0 java
> > [162005.262615] Memory cgroup out of memory: Kill process 3002 (java7) score
> > 662 or sacrifice child
> > [162005.262623] Killed process 3002 (java7) total-vm:2176612kB,
> > anon-rss:60400kB, file-rss:28576kB

Nothing unusual here.

[fixed up line wraps]
> [162005.263453] general protection fault: 0000 [#1] SMP
> [162005.263463] Modules linked in: ipv6 dm_mod xen_netfront coretemp hwmon x86_pkg_temp_thermal crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel ablk_helper cryptd lrw gf128mul glue_helper aes_x86_64 microcode pcspkr ext4 jbd2 mbcache raid0 xen_blkfront
> [162005.264060] CPU: 3 PID: 3062 Comm: java Not tainted 3.16.0-rc5 #1
> [162005.264060] task: ffff8801cfe8f170 ti: ffff8801d2ec4000 task.ti: ffff8801d2ec4000
> [162005.264060] RIP: e030:[<ffffffff811c0b80>]  [<ffffffff811c0b80>] mem_cgroup_oom_synchronize+0x140/0x240
> [162005.264060] RSP: e02b:ffff8801d2ec7d48  EFLAGS: 00010283
> [162005.264060] RAX: 0000000000000001 RBX: ffff88009d633800 RCX: 000000000000000e
> [162005.264060] RDX: fffffffffffffffe RSI: ffff88009d630200 RDI: ffff88009d630200
> [162005.264060] RBP: ffff8801d2ec7da8 R08: 0000000000000012 R09: 00000000fffffffe
> [162005.264060] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88009d633800
> [162005.264060] R13: ffff8801d2ec7d48 R14: dead000000100100 R15: ffff88009d633a30
> [162005.264060] FS:  00007f1748bb4700(0000) GS:ffff8801def80000(0000) knlGS:0000000000000000
> [162005.264060] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> [162005.264060] CR2: 00007f4110300308 CR3: 00000000c05f7000 CR4: 0000000000002660
> [162005.264060] Stack:
> [162005.264060]  ffff88009d633800 0000000000000000 ffff8801cfe8f170 ffffffff811bae10
> [162005.264060]  ffffffff81ca73f8 ffffffff81ca73f8 ffff8801d2ec7dc8 0000000000000006
> [162005.264060]  00000000e3b30000 00000000e3b30000 ffff8801d2ec7f58 0000000000000001
> [162005.264060] Call Trace:
> [162005.264060]  [<ffffffff811bae10>] ? mem_cgroup_wait_acct_move+0x110/0x110
> [162005.264060]  [<ffffffff81159628>] pagefault_out_of_memory+0x18/0x90
> [162005.264060]  [<ffffffff8105cee9>] mm_fault_error+0xa9/0x1a0
> [162005.264060]  [<ffffffff8105d488>] __do_page_fault+0x478/0x4c0
> [162005.264060]  [<ffffffff81004f00>] ? xen_mc_flush+0xb0/0x1b0
> [162005.264060]  [<ffffffff81003ab3>] ? xen_write_msr_safe+0xa3/0xd0
> [162005.264060]  [<ffffffff81012a40>] ? __switch_to+0x2d0/0x600
> [162005.264060]  [<ffffffff8109e273>] ? finish_task_switch+0x53/0xf0
> [162005.264060]  [<ffffffff81643b0a>] ? __schedule+0x37a/0x6d0
> [162005.264060]  [<ffffffff8105d5dc>] do_page_fault+0x2c/0x40
> [162005.264060]  [<ffffffff81649858>] page_fault+0x28/0x30
> [162005.264060] Code: 44 00 00 48 89 df e8 40 ca ff ff 48 85 c0 49 89 c4 74 35 4c 8b b0 30 02 00 00 4c 8d b8 30 02 00 00 4d 39 fe 74 1b 0f 1f 44 00 00 <49> 8b 7e 10 be 01 00 00 00 e8 42 d2 04 00 4d 8b 36 4d 39 fe 75
> [162005.264060] RIP  [<ffffffff811c0b80>] mem_cgroup_oom_synchronize+0x140/0x240
> [162005.264060]  RSP <ffff8801d2ec7d48>
> [162005.458051] ---[ end trace 050b00c5503ce96a ]---

This decodes to:
[162005.264060] Code: 44 00 00 48 89 df e8 40 ca ff ff 48 85 c0 49 89 c4 74 35 4c 8b b0 30 02 00 00 4c 8d b8 30 02 00 00 4d 39 fe 74 1b 0f 1f 44 00 00 <49> 8b 7e 10 be 01 00 00 00 e8 42 d2 04 00 4d 8b 36 4d 39 fe 75
All code
========
   0:   44 00 00                add    %r8b,(%rax)
   3:   48 89 df                mov    %rbx,%rdi
   6:   e8 40 ca ff ff          callq  0xffffffffffffca4b
   b:   48 85 c0                test   %rax,%rax
   e:   49 89 c4                mov    %rax,%r12
  11:   74 35                   je     0x48
  13:   4c 8b b0 30 02 00 00    mov    0x230(%rax),%r14
  1a:   4c 8d b8 30 02 00 00    lea    0x230(%rax),%r15
  21:   4d 39 fe                cmp    %r15,%r14
  24:   74 1b                   je     0x41
  26:   0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
  2b:*  49 8b 7e 10             mov    0x10(%r14),%rdi          <-- trapping instruction
  2f:   be 01 00 00 00          mov    $0x1,%esi
  34:   e8 42 d2 04 00          callq  0x4d27b
  39:   4d 8b 36                mov    (%r14),%r14
  3c:   4d 39 fe                cmp    %r15,%r14
  3f:   75                      .byte 0x75

R14 is dead000000100100 which is a poison value. If I am reading the
code correctly this should be somewhere in mem_cgroup_oom_notify_cb
where we stumble over event which has been removed from the notify chain.

And indeed there is nothing to protect the oom_notify chain in the oom
path.  {Un}Registration is protected by memcg_oom_lock and that one is
used in mem_cgroup_oom_trylock but it is taken only locally in that
function. The issue seems to be introduced by fb2a6fc56be6 (mm: memcg:
rework and document OOM waiting and wakeup) in 3.12.

The most simplistic fix would be simply using memcg_oom_lock inside
mem_cgroup_oom_notify_cb, but I cannot say I would like it much. Another
approach would be using RCU for mem_cgroup_eventfd_list deallocation and
{un}linking.

Let's go with simpler route for now as this is not a hot path, though.
---
