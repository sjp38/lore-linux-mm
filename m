Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 84D816B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 09:01:28 -0400 (EDT)
Received: by qwf7 with SMTP id 7so6243180qwf.14
        for <linux-mm@kvack.org>; Tue, 21 Sep 2010 06:01:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTikN7XN3hymsmqH05nynAHH9st0W2pkDhoCLUTo9@mail.gmail.com>
References: <20100727200804.2F40.A69D9226@jp.fujitsu.com> <AANLkTin47_htYK8eV-6C4QkRK_U__qYeWX16Ly=YK-0w@mail.gmail.com>
 <20100728135850.7A92.A69D9226@jp.fujitsu.com> <AANLkTi=fk8B-TnC6m3AoLT7k_G239rMaQA1COwHLxwRM@mail.gmail.com>
 <AANLkTikq=v_7dbW1Z+LUbTKmnezKT0cd8ZTErwP1X0C+@mail.gmail.com> <AANLkTikN7XN3hymsmqH05nynAHH9st0W2pkDhoCLUTo9@mail.gmail.com>
From: dave b <db.pub.mail@gmail.com>
Date: Tue, 21 Sep 2010 23:01:03 +1000
Message-ID: <AANLkTin2sAc88VPHvq3-OQTDYrmZQfUe=QzzXa8y3iai@mail.gmail.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ok this issue is still around and still *really* annoying.
So I had a 5mb text file, I put %s/\n/, in vim, my desktop stalls as
vim uses memory it sits there for ~10 minutes before finally the oom
killer wakes up and does something....
This is on totally different hardware now(amd phenom ddr3 ram, SATA 3
disk) and Here is some dmesg output :)


ep 21 22:41:44 RANDOMBOXEN kernel: [329160.956367] kjournald     D
ffff88011be59a00     0   982      2 0x00000000
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956370]  ffff88011bf9fbf0
0000000000000046 ffff88011bf9fbc0 ffffffffa00f0775
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956373]  ffff88011bf9ffd8
0000000000013900 ffff88011bf9ffd8 ffff88011be59680
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956375]  0000000000013900
0000000000013900 0000000000013900 0000000000013900
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956377] Call Trace:
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956399]
[<ffffffffa00f0775>] ? dm_table_unplug_all+0x54/0xc6 [dm_mod]
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956405]
[<ffffffff812e4f80>] io_schedule+0x7b/0xc1
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956408]
[<ffffffff8110d0ea>] sync_buffer+0x3b/0x3f
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956409]
[<ffffffff812e5488>] __wait_on_bit+0x47/0x79
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956411]
[<ffffffff8110d0af>] ? sync_buffer+0x0/0x3f
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956413]
[<ffffffff8110d0af>] ? sync_buffer+0x0/0x3f
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956415]
[<ffffffff812e5524>] out_of_line_wait_on_bit+0x6a/0x77
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956418]
[<ffffffff8105b678>] ? wake_bit_function+0x0/0x2a
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956419]
[<ffffffff8110d06f>] __wait_on_buffer+0x1f/0x21
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956425]
[<ffffffffa0165824>] journal_commit_transaction+0xa42/0xfba [jbd]
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956427]
[<ffffffff812e4e36>] ? schedule+0x64d/0x71c
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956430]
[<ffffffff8104fe0a>] ? lock_timer_base+0x26/0x4a
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956432]
[<ffffffff8104fee4>] ? try_to_del_timer_sync+0xb6/0xc3
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956437]
[<ffffffffa0168942>] kjournald+0xef/0x23b [jbd]
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956439]
[<ffffffff8105b640>] ? autoremove_wake_function+0x0/0x38
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956444]
[<ffffffffa0168853>] ? kjournald+0x0/0x23b [jbd]
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956446]
[<ffffffff8105b1ae>] kthread+0x7d/0x85
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956449]
[<ffffffff81003964>] kernel_thread_helper+0x4/0x10
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956451]
[<ffffffff8105b131>] ? kthread+0x0/0x85
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956453]
[<ffffffff81003960>] ? kernel_thread_helper+0x0/0x10
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956461] openvpn       D
ffff88011beb3080     0  2196      1 0x00000000
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956463]  ffff88011bc51cb8
0000000000000086 0000000000000282 00000000f9897afa
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956469]  ffff88011bc51fd8
0000000000013900 ffff88011bc51fd8 ffff88011beb2d00
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956471]  0000000000013900
0000000000013900 0000000000013900 0000000000013900
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956473] Call Trace:
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956475]
[<ffffffff812e4f80>] io_schedule+0x7b/0xc1
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956477]
[<ffffffff810b0e18>] sync_page+0x41/0x45
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956478]
[<ffffffff812e5383>] __wait_on_bit_lock+0x45/0x8c
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956480]
[<ffffffff810b0dd7>] ? sync_page+0x0/0x45
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956481]
[<ffffffff810b0dc3>] __lock_page+0x63/0x6a
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956483]
[<ffffffff8105b678>] ? wake_bit_function+0x0/0x2a
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956486]
[<ffffffff810c857d>] handle_mm_fault+0x61f/0x93e
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956491]
[<ffffffffa017b06e>] ? ext3_dirty_inode+0x7b/0x83 [ext3]
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956494]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956496]
[<ffffffff810ff51a>] ? notify_change+0x298/0x2aa
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956498]
[<ffffffff810ead20>] ? do_truncate+0x7b/0x86
Sep 21 22:41:44 RANDOMBOXEN kernel: [329160.956500]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956504] postgres      D
ffff88011ced9a00     0  2241   2237 0x00000000
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956506]  ffff88011bc4fb78
0000000000000086 ffff88011bc4fc38 000000003b0edb74
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956508]  ffff88011bc4ffd8
0000000000013900 ffff88011bc4ffd8 ffff88011ced9680
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956510]  0000000000013900
0000000000013900 0000000000013900 0000000000013900
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956511] Call Trace:
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956513]
[<ffffffff812e4f80>] io_schedule+0x7b/0xc1
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956515]
[<ffffffff810b0e18>] sync_page+0x41/0x45
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956516]
[<ffffffff812e5383>] __wait_on_bit_lock+0x45/0x8c
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956518]
[<ffffffff810b0dd7>] ? sync_page+0x0/0x45
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956519]
[<ffffffff810b0dc3>] __lock_page+0x63/0x6a
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956521]
[<ffffffff8105b678>] ? wake_bit_function+0x0/0x2a
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956523]
[<ffffffff810b0ef2>] find_lock_page+0x39/0x5d
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956524]
[<ffffffff810b159e>] filemap_fault+0x1cc/0x31f
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956526]
[<ffffffff810c5e40>] __do_fault+0x50/0x413
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956528]
[<ffffffff810c8433>] handle_mm_fault+0x4d5/0x93e
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956530]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956531]
[<ffffffff810cc37c>] ? unmap_region+0x125/0x13b
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956533]
[<ffffffff810cc107>] ? remove_vma+0x64/0x6c
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956534]
[<ffffffff810cd398>] ? do_munmap+0x31a/0x33e
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956536]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956541] Xorg          D
ffff88011d6c4700     0  2472   2470 0x00400004
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956543]  ffff88011cc75b78
0000000000003086 ffff88011cc75c38 00000000047655ff
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956545]  ffff88011cc75fd8
0000000000013900 ffff88011cc75fd8 ffff88011d6c4380
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956546]  0000000000013900
0000000000013900 0000000000013900 0000000000013900
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956548] Call Trace:
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956550]
[<ffffffff812e4f80>] io_schedule+0x7b/0xc1
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956552]
[<ffffffff810b0e18>] sync_page+0x41/0x45
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956553]
[<ffffffff812e5383>] __wait_on_bit_lock+0x45/0x8c
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956554]
[<ffffffff810b0dd7>] ? sync_page+0x0/0x45
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956556]
[<ffffffff810b0dc3>] __lock_page+0x63/0x6a
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956558]
[<ffffffff8105b678>] ? wake_bit_function+0x0/0x2a
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956559]
[<ffffffff810b0ef2>] find_lock_page+0x39/0x5d
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956561]
[<ffffffff810b159e>] filemap_fault+0x1cc/0x31f
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956563]
[<ffffffff810c5e40>] __do_fault+0x50/0x413
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956565]
[<ffffffff810c8433>] handle_mm_fault+0x4d5/0x93e
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956567]
[<ffffffff8105478c>] ? get_signal_to_deliver+0x123/0x3ab
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956569]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956571]
[<ffffffff8100ba65>] ? restore_i387_xstate+0x6e/0x168
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956573]
[<ffffffff81154dbe>] ? security_file_permission+0x11/0x13
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956575]
[<ffffffff810028ec>] ? sys_rt_sigreturn+0x1e8/0x23c
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956577]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956581] apache2       D
ffff88011bc04700     0  2547      1 0x00000000
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956583]  ffff88011d7cdb78
0000000000000082 ffff88011d7cdc38 00000000e2f0079f
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956584]  ffff88011d7cdfd8
0000000000013900 ffff88011d7cdfd8 ffff88011bc04380
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956586]  0000000000013900
0000000000013900 0000000000013900 0000000000013900
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956588] Call Trace:
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956590]
[<ffffffff812e4f80>] io_schedule+0x7b/0xc1
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956591]
[<ffffffff810b0e18>] sync_page+0x41/0x45
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956593]
[<ffffffff812e5383>] __wait_on_bit_lock+0x45/0x8c
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956594]
[<ffffffff810b0dd7>] ? sync_page+0x0/0x45
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956596]
[<ffffffff810b0dc3>] __lock_page+0x63/0x6a
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956597]
[<ffffffff8105b678>] ? wake_bit_function+0x0/0x2a
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956599]
[<ffffffff810b0ef2>] find_lock_page+0x39/0x5d
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956601]
[<ffffffff810b159e>] filemap_fault+0x1cc/0x31f
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956603]
[<ffffffff810c5e40>] __do_fault+0x50/0x413
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956604]
[<ffffffff812e53bc>] ? __wait_on_bit_lock+0x7e/0x8c
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956606]
[<ffffffff810c8433>] handle_mm_fault+0x4d5/0x93e
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956608]
[<ffffffff8100350e>] ? apic_timer_interrupt+0xe/0x20
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956609]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956611]
[<ffffffff810f9504>] ? poll_select_copy_remaining+0xc5/0xe9
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956613]
[<ffffffff810fa820>] ? sys_select+0xa7/0xbc
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956615]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956619] gconfd-2      D
ffff8801150c4700     0  2622      1 0x00000000
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956621]  ffff8801151b1cb8
0000000000000086 0000000000000282 00000000f8220c09
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956623]  ffff8801151b1fd8
0000000000013900 ffff8801151b1fd8 ffff8801150c4380
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956625]  0000000000013900
0000000000013900 0000000000013900 0000000000013900
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956626] Call Trace:
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956628]
[<ffffffff812e4f80>] io_schedule+0x7b/0xc1
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956630]
[<ffffffff810b0e18>] sync_page+0x41/0x45
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956631]
[<ffffffff812e5383>] __wait_on_bit_lock+0x45/0x8c
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956633]
[<ffffffff810b0dd7>] ? sync_page+0x0/0x45
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956634]
[<ffffffff810b0dc3>] __lock_page+0x63/0x6a
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956636]
[<ffffffff8105b678>] ? wake_bit_function+0x0/0x2a
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956638]
[<ffffffff810c857d>] handle_mm_fault+0x61f/0x93e
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956639]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956641]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956646] gnome-panel   D
ffff88011beb1a00     0  2741   2625 0x00000000
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956648]  ffff880111fa1cb8
0000000000000086 0000000000000282 0000000038a28654
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956650]  ffff880111fa1fd8
0000000000013900 ffff880111fa1fd8 ffff88011beb1680
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956652]  0000000000013900
0000000000013900 0000000000013900 0000000000013900
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956653] Call Trace:
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956655]
[<ffffffff812e4f80>] io_schedule+0x7b/0xc1
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956657]
[<ffffffff810b0e18>] sync_page+0x41/0x45
Sep 21 22:41:45 RANDOMBOXEN kernel: [329160.956658]
[<ffffffff812e5383>] __wait_on_bit_lock+0x45/0x8c
Sep 21 22:41:46 RANDOMBOXEN kernel: [329160.956660]
[<ffffffff810b0dd7>] ? sync_page+0x0/0x45
Sep 21 22:41:46 RANDOMBOXEN kernel: [329160.956661]
[<ffffffff810b0dc3>] __lock_page+0x63/0x6a
Sep 21 22:41:46 RANDOMBOXEN kernel: [329160.956663]
[<ffffffff8105b678>] ? wake_bit_function+0x0/0x2a
Sep 21 22:41:46 RANDOMBOXEN kernel: [329160.956665]
[<ffffffff810c857d>] handle_mm_fault+0x61f/0x93e
Sep 21 22:41:46 RANDOMBOXEN kernel: [329160.956666]
[<ffffffff810f578d>] ? putname+0x30/0x39
Sep 21 22:41:46 RANDOMBOXEN kernel: [329160.956668]
[<ffffffff810f7156>] ? user_path_at+0x5d/0x8c
Sep 21 22:41:46 RANDOMBOXEN kernel: [329160.956669]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:41:46 RANDOMBOXEN kernel: [329160.956671]
[<ffffffff810ef0b0>] ? sys_newstat+0x2c/0x3b
Sep 21 22:41:46 RANDOMBOXEN kernel: [329160.956673]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956677] nautilus      D
ffff880111f31a00     0  2743   2625 0x00000000
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956679]  ffff880111e69cb8
0000000000000086 0000000000000282 00000000d6f5b63a
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956680]  ffff880111e69fd8
0000000000013900 ffff880111e69fd8 ffff880111f31680
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956682]  0000000000013900
0000000000013900 0000000000013900 0000000000013900
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956684] Call Trace:
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956686]
[<ffffffff812e4f80>] io_schedule+0x7b/0xc1
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956687]
[<ffffffff810b0e18>] sync_page+0x41/0x45
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956689]
[<ffffffff812e5383>] __wait_on_bit_lock+0x45/0x8c
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956690]
[<ffffffff810b0dd7>] ? sync_page+0x0/0x45
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956691]
[<ffffffff810b0dc3>] __lock_page+0x63/0x6a
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956693]
[<ffffffff8105b678>] ? wake_bit_function+0x0/0x2a
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956695]
[<ffffffff810c857d>] handle_mm_fault+0x61f/0x93e
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956697]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956699]
[<ffffffff81009861>] ? read_tsc+0xe/0x25
Sep 21 22:41:47 RANDOMBOXEN kernel: [329160.956701]
[<ffffffff8106342d>] ? ktime_get_ts+0xb1/0xbe
Sep 21 22:41:54 RANDOMBOXEN kernel: [329160.956703]
[<ffffffff810f9662>] ? poll_select_set_timeout+0x5c/0x77
Sep 21 22:41:54 RANDOMBOXEN kernel: [329160.956704]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:41:54 RANDOMBOXEN kernel: [329160.956708] update-notifi D
ffff88011089b080     0  2752   2625 0x00000000
Sep 21 22:41:59 RANDOMBOXEN kernel: [329160.956710]  ffff88011090dcb8
0000000000000086 0000000000000282 00000000c088e457
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956712]  ffff88011090dfd8
0000000000013900 ffff88011090dfd8 ffff88011089ad00
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956714]  0000000000013900
0000000000013900 0000000000013900 0000000000013900
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956715] Call Trace:
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956717]
[<ffffffff812e4f80>] io_schedule+0x7b/0xc1
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956719]
[<ffffffff810b0e18>] sync_page+0x41/0x45
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956720]
[<ffffffff812e5383>] __wait_on_bit_lock+0x45/0x8c
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956722]
[<ffffffff810b0dd7>] ? sync_page+0x0/0x45
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956723]
[<ffffffff810b0dc3>] __lock_page+0x63/0x6a
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956725]
[<ffffffff8105b678>] ? wake_bit_function+0x0/0x2a
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956727]
[<ffffffff810c857d>] handle_mm_fault+0x61f/0x93e
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956729]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956730]
[<ffffffff81009861>] ? read_tsc+0xe/0x25
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956732]
[<ffffffff8106342d>] ? ktime_get_ts+0xb1/0xbe
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956734]
[<ffffffff810f9662>] ? poll_select_set_timeout+0x5c/0x77
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956735]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956739] nm-applet     D
ffff88011089dd80     0  2762   2625 0x00000000
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956741]  ffff880110a27cb8
0000000000000082 0000000000000282 0000000008ebc327
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956743]  ffff880110a27fd8
0000000000013900 ffff880110a27fd8 ffff88011089da00
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956745]  0000000000013900
0000000000013900 0000000000013900 0000000000013900
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956747] Call Trace:
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956749]
[<ffffffff812e4f80>] io_schedule+0x7b/0xc1
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956750]
[<ffffffff810b0e18>] sync_page+0x41/0x45
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956751]
[<ffffffff812e5383>] __wait_on_bit_lock+0x45/0x8c
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956753]
[<ffffffff810b0dd7>] ? sync_page+0x0/0x45
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956754]
[<ffffffff810b0dc3>] __lock_page+0x63/0x6a
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956756]
[<ffffffff8105b678>] ? wake_bit_function+0x0/0x2a
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956758]
[<ffffffff810c857d>] handle_mm_fault+0x61f/0x93e
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956760]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956761]
[<ffffffff81009861>] ? read_tsc+0xe/0x25
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956763]
[<ffffffff8100350e>] ? apic_timer_interrupt+0xe/0x20
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956765]
[<ffffffff8106342d>] ? ktime_get_ts+0xb1/0xbe
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956767]
[<ffffffff810f9662>] ? poll_select_set_timeout+0x5c/0x77
Sep 21 22:42:16 RANDOMBOXEN kernel: [329160.956768]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481246] gnome-volume-ma
invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481250] gnome-volume-ma
cpuset=/ mems_allowed=0
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481253] Pid: 2769, comm:
gnome-volume-ma Not tainted 2.6.35.4 #1
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481255] Call Trace:
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481262]
[<ffffffff810824f1>] ? cpuset_print_task_mems_allowed+0x8d/0x98
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481265]
[<ffffffff810b2e89>] dump_header+0x65/0x182
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481269]
[<ffffffff8119031b>] ? ___ratelimit+0xc7/0xe4
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481271]
[<ffffffff810b2feb>] oom_kill_process+0x45/0x110
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481273]
[<ffffffff810b3439>] __out_of_memory+0x143/0x15a
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481275]
[<ffffffff810b35a1>] out_of_memory+0x151/0x183
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481278]
[<ffffffff810b726b>] __alloc_pages_nodemask+0x550/0x6a1
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481281]
[<ffffffff810de22b>] alloc_pages_current+0xa8/0xd1
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481283]
[<ffffffff810b108a>] __page_cache_alloc+0x77/0x82
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481286]
[<ffffffff810b88ce>] __do_page_cache_readahead+0x96/0x1a2
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481288]
[<ffffffff810b89f6>] ra_submit+0x1c/0x20
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481290]
[<ffffffff810b1582>] filemap_fault+0x1b0/0x31f
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481293]
[<ffffffff810c5e40>] __do_fault+0x50/0x413
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481296]
[<ffffffff812e53bc>] ? __wait_on_bit_lock+0x7e/0x8c
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481298]
[<ffffffff810b0dd7>] ? sync_page+0x0/0x45
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481301]
[<ffffffff810c8433>] handle_mm_fault+0x4d5/0x93e
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481304]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481307]
[<ffffffff81009861>] ? read_tsc+0xe/0x25
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481310]
[<ffffffff8106342d>] ? ktime_get_ts+0xb1/0xbe
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481313]
[<ffffffff810f9662>] ? poll_select_set_timeout+0x5c/0x77
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481316]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481318] Mem-Info:
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481319] Node 0 DMA per-cpu:
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481321] CPU    0: hi:
0, btch:   1 usd:   0
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481323] CPU    1: hi:
0, btch:   1 usd:   0
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481324] CPU    2: hi:
0, btch:   1 usd:   0
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481325] CPU    3: hi:
0, btch:   1 usd:   0
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481327] CPU    4: hi:
0, btch:   1 usd:   0
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481328] CPU    5: hi:
0, btch:   1 usd:   0
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481329] Node 0 DMA32 per-cpu:
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481331] CPU    0: hi:
186, btch:  31 usd: 179
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481332] CPU    1: hi:
186, btch:  31 usd: 183
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481333] CPU    2: hi:
186, btch:  31 usd: 196
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481335] CPU    3: hi:
186, btch:  31 usd: 202
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481336] CPU    4: hi:
186, btch:  31 usd: 176
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481337] CPU    5: hi:
186, btch:  31 usd: 166
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481338] Node 0 Normal per-cpu:
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481340] CPU    0: hi:
186, btch:  31 usd: 160
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481341] CPU    1: hi:
186, btch:  31 usd: 175
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481342] CPU    2: hi:
186, btch:  31 usd: 156
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481343] CPU    3: hi:
186, btch:  31 usd: 158
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481345] CPU    4: hi:
186, btch:  31 usd: 146
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481346] CPU    5: hi:
186, btch:  31 usd: 186
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481349] active_anon:668154
inactive_anon:166010 isolated_anon:544
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481350]  active_file:172
inactive_file:213 isolated_file:0
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481351]  unevictable:1349
dirty:0 writeback:166443 unstable:0
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481352]  free:5834
slab_reclaimable:5297 slab_unreclaimable:44051
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481352]  mapped:762
shmem:22 pagetables:13167 bounce:0
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481354] Node 0 DMA
free:15004kB min:28kB low:32kB high:40kB active_anon:48kB
inactive_anon:256kB active_file:0kB inactive_file:0kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:15688kB mlocked:0kB
dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
slab_unreclaimable:560kB kernel_stack:0kB pagetables:0kB unstable:0kB
bounce:0kB writeback_tmp:0kB pages_scanned:576 all_unreclaimable? yes
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481361] lowmem_reserve[]:
0 3254 3759 3759
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481363] Node 0 DMA32
free:7412kB min:6780kB low:8472kB high:10168kB active_anon:2519256kB
inactive_anon:507512kB active_file:0kB inactive_file:52kB
unevictable:2912kB isolated(anon):2176kB isolated(file):0kB
present:3332768kB mlocked:2912kB dirty:0kB writeback:509772kB
mapped:96kB shmem:68kB slab_reclaimable:13044kB
slab_unreclaimable:99424kB kernel_stack:1392kB pagetables:32212kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:4732464
all_unreclaimable? yes
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481371] lowmem_reserve[]:
0 0 505 505
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481372] Node 0 Normal
free:920kB min:1052kB low:1312kB high:1576kB active_anon:153312kB
inactive_anon:156272kB active_file:688kB inactive_file:800kB
unevictable:2484kB isolated(anon):0kB isolated(file):0kB
present:517120kB mlocked:2484kB dirty:0kB writeback:156000kB
mapped:2952kB shmem:20kB slab_reclaimable:8144kB
slab_unreclaimable:76220kB kernel_stack:1576kB pagetables:20456kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:555904
all_unreclaimable? yes
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481379] lowmem_reserve[]: 0 0 0 0
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481381] Node 0 DMA: 15*4kB
4*8kB 2*16kB 5*32kB 2*64kB 2*128kB 2*256kB 1*512kB 1*1024kB 2*2048kB
2*4096kB = 15004kB
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481386] Node 0 DMA32:
1041*4kB 2*8kB 8*16kB 11*32kB 5*64kB 5*128kB 3*256kB 0*512kB 1*1024kB
0*2048kB 0*4096kB = 7412kB
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481391] Node 0 Normal:
230*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
0*2048kB 0*4096kB = 920kB
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481396] 168181 total pagecache pages
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481397] 167149 pages in swap cache
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481398] Swap cache stats:
add 2171614, delete 2004465, find 789342/867065
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481400] Free swap  = 456344kB
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.481400] Total swap = 5947388kB
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.495910] 983024 pages RAM
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.495911] 32468 pages reserved
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.495912] 29764 pages shared
Sep 21 22:42:16 RANDOMBOXEN kernel: [329348.495912] 939943 pages non-shared
Sep 21 22:42:39 RANDOMBOXEN kernel: [329431.629246] vim invoked
oom-killer: gfp_mask=0x280da, order=0, oom_adj=0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629246] vim cpuset=/ mems_allowed=0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629246] Pid: 27080, comm:
vim Not tainted 2.6.35.4 #1
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629246] Call Trace:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629246]
[<ffffffff810824f1>] ? cpuset_print_task_mems_allowed+0x8d/0x98
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629246]
[<ffffffff810b2e89>] dump_header+0x65/0x182
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629246]
[<ffffffff8119031b>] ? ___ratelimit+0xc7/0xe4
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629246]
[<ffffffff810b2feb>] oom_kill_process+0x45/0x110
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629247]
[<ffffffff810b3439>] __out_of_memory+0x143/0x15a
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629249]
[<ffffffff810b35a1>] out_of_memory+0x151/0x183
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629251]
[<ffffffff810b726b>] __alloc_pages_nodemask+0x550/0x6a1
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629254]
[<ffffffff810de369>] alloc_page_vma+0x115/0x134
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629257]
[<ffffffff810c82cb>] handle_mm_fault+0x36d/0x93e
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629259]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629261]
[<ffffffff810cdbb0>] ? do_brk+0x22d/0x320
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629264]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629265] Mem-Info:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629266] Node 0 DMA per-cpu:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629268] CPU    0: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629269] CPU    1: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629270] CPU    2: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629272] CPU    3: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629273] CPU    4: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629274] CPU    5: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629275] Node 0 DMA32 per-cpu:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629276] CPU    0: hi:
186, btch:  31 usd:  34
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629277] CPU    1: hi:
186, btch:  31 usd: 149
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629278] CPU    2: hi:
186, btch:  31 usd:  72
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629279] CPU    3: hi:
186, btch:  31 usd:  49
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629280] CPU    4: hi:
186, btch:  31 usd:  38
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629281] CPU    5: hi:
186, btch:  31 usd: 158
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629282] Node 0 Normal per-cpu:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629283] CPU    0: hi:
186, btch:  31 usd:  82
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629284] CPU    1: hi:
186, btch:  31 usd: 179
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629285] CPU    2: hi:
186, btch:  31 usd:  98
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629287] CPU    3: hi:
186, btch:  31 usd:  33
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629288] CPU    4: hi:
186, btch:  31 usd: 104
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629289] CPU    5: hi:
186, btch:  31 usd: 138
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629292] active_anon:694864
inactive_anon:174958 isolated_anon:0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629292]  active_file:317
inactive_file:391 isolated_file:0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629293]  unevictable:1350
dirty:10 writeback:386 unstable:0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629293]  free:6107
slab_reclaimable:4729 slab_unreclaimable:9023
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629294]  mapped:921
shmem:22 pagetables:13597 bounce:0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629295] Node 0 DMA
free:15040kB min:28kB low:32kB high:40kB active_anon:336kB
inactive_anon:416kB active_file:0kB inactive_file:0kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:15688kB mlocked:0kB
dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
slab_unreclaimable:72kB kernel_stack:0kB pagetables:4kB unstable:0kB
bounce:0kB writeback_tmp:0kB pages_scanned:32 all_unreclaimable? yes
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629301] lowmem_reserve[]:
0 3254 3759 3759
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629303] Node 0 DMA32
free:8652kB min:6780kB low:8472kB high:10168kB active_anon:2594112kB
inactive_anon:514336kB active_file:4kB inactive_file:124kB
unevictable:2916kB isolated(anon):0kB isolated(file):0kB
present:3332768kB mlocked:2916kB dirty:8kB writeback:1540kB
mapped:16kB shmem:64kB slab_reclaimable:11076kB
slab_unreclaimable:20900kB kernel_stack:1160kB pagetables:33188kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:192
all_unreclaimable? yes
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629309] lowmem_reserve[]:
0 0 505 505
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629311] Node 0 Normal
free:736kB min:1052kB low:1312kB high:1576kB active_anon:185008kB
inactive_anon:185080kB active_file:1264kB inactive_file:1440kB
unevictable:2484kB isolated(anon):0kB isolated(file):0kB
present:517120kB mlocked:2484kB dirty:32kB writeback:4kB mapped:3668kB
shmem:24kB slab_reclaimable:7840kB slab_unreclaimable:15120kB
kernel_stack:1592kB pagetables:21196kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:4320 all_unreclaimable? yes
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629317] lowmem_reserve[]: 0 0 0 0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629318] Node 0 DMA: 2*4kB
3*8kB 2*16kB 2*32kB 3*64kB 1*128kB 1*256kB 0*512kB 2*1024kB 2*2048kB
2*4096kB = 15040kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629323] Node 0 DMA32:
1328*4kB 2*8kB 10*16kB 10*32kB 6*64kB 5*128kB 3*256kB 0*512kB 1*1024kB
0*2048kB 0*4096kB = 8624kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629327] Node 0 Normal:
186*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
0*2048kB 0*4096kB = 744kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629331] 34872 total pagecache pages
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629332] 33392 pages in swap cache
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629333] Swap cache stats:
add 2310505, delete 2277113, find 790781/869652
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629334] Free swap  = 0kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.629334] Total swap = 5947388kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.643262] 983024 pages RAM
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.643263] 32468 pages reserved
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.643264] 28528 pages shared
Sep 21 22:42:40 RANDOMBOXEN kernel: [329431.643265] 941544 pages non-shared
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440409] vim invoked
oom-killer: gfp_mask=0x280da, order=0, oom_adj=0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440413] vim cpuset=/ mems_allowed=0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440415] Pid: 27080, comm:
vim Not tainted 2.6.35.4 #1
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440416] Call Trace:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440422]
[<ffffffff810824f1>] ? cpuset_print_task_mems_allowed+0x8d/0x98
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440425]
[<ffffffff810b2e89>] dump_header+0x65/0x182
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440429]
[<ffffffff8119031b>] ? ___ratelimit+0xc7/0xe4
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440431]
[<ffffffff810b2feb>] oom_kill_process+0x45/0x110
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440433]
[<ffffffff810b3439>] __out_of_memory+0x143/0x15a
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440435]
[<ffffffff810b35a1>] out_of_memory+0x151/0x183
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440438]
[<ffffffff810b726b>] __alloc_pages_nodemask+0x550/0x6a1
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440440]
[<ffffffff810de369>] alloc_page_vma+0x115/0x134
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440443]
[<ffffffff810c82cb>] handle_mm_fault+0x36d/0x93e
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440447]
[<ffffffff8100358e>] ? invalidate_interrupt2+0xe/0x20
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440449]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440451]
[<ffffffff810cdbb0>] ? do_brk+0x22d/0x320
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440455]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440456] Mem-Info:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440457] Node 0 DMA per-cpu:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440459] CPU    0: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440460] CPU    1: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440462] CPU    2: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440463] CPU    3: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440464] CPU    4: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440465] CPU    5: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440466] Node 0 DMA32 per-cpu:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440468] CPU    0: hi:
186, btch:  31 usd:  83
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440469] CPU    1: hi:
186, btch:  31 usd: 174
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440471] CPU    2: hi:
186, btch:  31 usd: 163
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440472] CPU    3: hi:
186, btch:  31 usd:  39
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440473] CPU    4: hi:
186, btch:  31 usd:  53
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440474] CPU    5: hi:
186, btch:  31 usd: 178
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440475] Node 0 Normal per-cpu:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440477] CPU    0: hi:
186, btch:  31 usd:  47
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440478] CPU    1: hi:
186, btch:  31 usd:  58
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440479] CPU    2: hi:
186, btch:  31 usd: 137
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440480] CPU    3: hi:
186, btch:  31 usd:  42
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440482] CPU    4: hi:
186, btch:  31 usd: 122
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440483] CPU    5: hi:
186, btch:  31 usd: 160
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440486] active_anon:693654
inactive_anon:175786 isolated_anon:0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440487]  active_file:199
inactive_file:716 isolated_file:0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440488]  unevictable:1350
dirty:0 writeback:439 unstable:0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440488]  free:6144
slab_reclaimable:4669 slab_unreclaimable:9109
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440489]  mapped:795
shmem:24 pagetables:13463 bounce:0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440491] Node 0 DMA
free:15040kB min:28kB low:32kB high:40kB active_anon:336kB
inactive_anon:416kB active_file:0kB inactive_file:0kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:15688kB mlocked:0kB
dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
slab_unreclaimable:72kB kernel_stack:0kB pagetables:4kB unstable:0kB
bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440497] lowmem_reserve[]:
0 3254 3759 3759
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440500] Node 0 DMA32
free:8580kB min:6780kB low:8472kB high:10168kB active_anon:2589352kB
inactive_anon:517648kB active_file:100kB inactive_file:1592kB
unevictable:2916kB isolated(anon):0kB isolated(file):0kB
present:3332768kB mlocked:2916kB dirty:0kB writeback:1756kB
mapped:120kB shmem:68kB slab_reclaimable:10980kB
slab_unreclaimable:21156kB kernel_stack:1160kB pagetables:32592kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2784
all_unreclaimable? yes
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440507] lowmem_reserve[]:
0 0 505 505
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440509] Node 0 Normal
free:956kB min:1052kB low:1312kB high:1576kB active_anon:184928kB
inactive_anon:185080kB active_file:696kB inactive_file:1272kB
unevictable:2484kB isolated(anon):0kB isolated(file):0kB
present:517120kB mlocked:2484kB dirty:0kB writeback:0kB mapped:3060kB
shmem:28kB slab_reclaimable:7696kB slab_unreclaimable:15208kB
kernel_stack:1592kB pagetables:21256kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:3040 all_unreclaimable? yes
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440516] lowmem_reserve[]: 0 0 0 0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440517] Node 0 DMA: 2*4kB
3*8kB 2*16kB 2*32kB 3*64kB 1*128kB 1*256kB 0*512kB 2*1024kB 2*2048kB
2*4096kB = 15040kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440522] Node 0 DMA32:
1208*4kB 68*8kB 14*16kB 10*32kB 6*64kB 5*128kB 3*256kB 0*512kB
1*1024kB 0*2048kB 0*4096kB = 8736kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440527] Node 0 Normal:
247*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
0*2048kB 0*4096kB = 988kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440532] 43587 total pagecache pages
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440533] 41932 pages in swap cache
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440534] Swap cache stats:
add 2321150, delete 2279218, find 790795/869679
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440535] Free swap  = 0kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.440536] Total swap = 5947388kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.454068] 983024 pages RAM
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.454069] 32468 pages reserved
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.454070] 27996 pages shared
Sep 21 22:42:40 RANDOMBOXEN kernel: [329443.454071] 941542 pages non-shared
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692683] vim invoked
oom-killer: gfp_mask=0x280da, order=0, oom_adj=0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692693] vim cpuset=/ mems_allowed=0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692700] Pid: 27080, comm:
vim Not tainted 2.6.35.4 #1
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692705] Call Trace:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692718]
[<ffffffff810824f1>] ? cpuset_print_task_mems_allowed+0x8d/0x98
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692729]
[<ffffffff810b2e89>] dump_header+0x65/0x182
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692738]
[<ffffffff8119031b>] ? ___ratelimit+0xc7/0xe4
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692745]
[<ffffffff810b2feb>] oom_kill_process+0x45/0x110
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692753]
[<ffffffff810b3439>] __out_of_memory+0x143/0x15a
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692760]
[<ffffffff810b35a1>] out_of_memory+0x151/0x183
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692768]
[<ffffffff810b726b>] __alloc_pages_nodemask+0x550/0x6a1
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692777]
[<ffffffff810de369>] alloc_page_vma+0x115/0x134
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692785]
[<ffffffff810c82cb>] handle_mm_fault+0x36d/0x93e
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692794]
[<ffffffff8100354e>] ? invalidate_interrupt0+0xe/0x20
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692802]
[<ffffffff8105ed39>] ? down_read_trylock+0x15/0x20
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692810]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692817]
[<ffffffff810cdbb0>] ? do_brk+0x22d/0x320
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692825]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692830] Mem-Info:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692833] Node 0 DMA per-cpu:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692839] CPU    0: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692844] CPU    1: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692848] CPU    2: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692853] CPU    3: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692857] CPU    4: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692861] CPU    5: hi:
0, btch:   1 usd:   0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692865] Node 0 DMA32 per-cpu:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692870] CPU    0: hi:
186, btch:  31 usd: 165
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692875] CPU    1: hi:
186, btch:  31 usd: 155
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692879] CPU    2: hi:
186, btch:  31 usd:  76
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692883] CPU    3: hi:
186, btch:  31 usd: 144
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692888] CPU    4: hi:
186, btch:  31 usd: 127
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692892] CPU    5: hi:
186, btch:  31 usd: 181
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692895] Node 0 Normal per-cpu:
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692900] CPU    0: hi:
186, btch:  31 usd:  30
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692905] CPU    1: hi:
186, btch:  31 usd:  60
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692909] CPU    2: hi:
186, btch:  31 usd:  37
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692913] CPU    3: hi:
186, btch:  31 usd: 154
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692918] CPU    4: hi:
186, btch:  31 usd:  94
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692922] CPU    5: hi:
186, btch:  31 usd:  81
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692933] active_anon:693215
inactive_anon:175789 isolated_anon:0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692936]  active_file:250
inactive_file:867 isolated_file:0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692938]  unevictable:1350
dirty:1 writeback:1426 unstable:0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692941]  free:6096
slab_reclaimable:4636 slab_unreclaimable:9159
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692943]  mapped:795
shmem:24 pagetables:13357 bounce:0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692948] Node 0 DMA
free:15040kB min:28kB low:32kB high:40kB active_anon:336kB
inactive_anon:416kB active_file:0kB inactive_file:0kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:15688kB mlocked:0kB
dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
slab_unreclaimable:72kB kernel_stack:0kB pagetables:4kB unstable:0kB
bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692972] lowmem_reserve[]:
0 3254 3759 3759
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.692979] Node 0 DMA32
free:8356kB min:6780kB low:8472kB high:10168kB active_anon:2588216kB
inactive_anon:518176kB active_file:180kB inactive_file:1772kB
unevictable:2916kB isolated(anon):0kB isolated(file):0kB
present:3332768kB mlocked:2916kB dirty:0kB writeback:4936kB
mapped:116kB shmem:68kB slab_reclaimable:10880kB
slab_unreclaimable:20960kB kernel_stack:1144kB pagetables:32148kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2976
all_unreclaimable? yes
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.693004] lowmem_reserve[]:
0 0 505 505
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.693011] Node 0 Normal
free:988kB min:1052kB low:1312kB high:1576kB active_anon:184308kB
inactive_anon:184564kB active_file:820kB inactive_file:1696kB
unevictable:2484kB isolated(anon):0kB isolated(file):0kB
present:517120kB mlocked:2484kB dirty:4kB writeback:768kB
mapped:3064kB shmem:28kB slab_reclaimable:7664kB
slab_unreclaimable:15604kB kernel_stack:1592kB pagetables:21276kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:4501
all_unreclaimable? yes
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.693035] lowmem_reserve[]: 0 0 0 0
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.693041] Node 0 DMA: 2*4kB
3*8kB 2*16kB 2*32kB 3*64kB 1*128kB 1*256kB 0*512kB 2*1024kB 2*2048kB
2*4096kB = 15040kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.693058] Node 0 DMA32:
1155*4kB 46*8kB 15*16kB 10*32kB 6*64kB 5*128kB 3*256kB 0*512kB
1*1024kB 0*2048kB 0*4096kB = 8364kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.693074] Node 0 Normal:
181*4kB 33*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
0*2048kB 0*4096kB = 988kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.693091] 36599 total pagecache pages
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.693094] 34748 pages in swap cache
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.693099] Swap cache stats:
add 2323833, delete 2289085, find 790812/869719
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.693103] Free swap  = 0kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.693106] Total swap = 5947388kB
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.725269] 983024 pages RAM
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.725272] 32468 pages reserved
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.725275] 27862 pages shared
Sep 21 22:42:40 RANDOMBOXEN kernel: [329446.725278] 941530 pages non-shared
Sep 21 22:42:45 RANDOMBOXEN kernel: [329456.848434] ntpd invoked
oom-killer: gfp_mask=0xd0, order=0, oom_adj=0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848444] ntpd cpuset=/ mems_allowed=0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848450] Pid: 2414, comm:
ntpd Not tainted 2.6.35.4 #1
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848455] Call Trace:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848468]
[<ffffffff810824f1>] ? cpuset_print_task_mems_allowed+0x8d/0x98
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848478]
[<ffffffff810b2e89>] dump_header+0x65/0x182
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848488]
[<ffffffff8119031b>] ? ___ratelimit+0xc7/0xe4
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848495]
[<ffffffff810b2feb>] oom_kill_process+0x45/0x110
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848502]
[<ffffffff810b3439>] __out_of_memory+0x143/0x15a
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848510]
[<ffffffff810b35a1>] out_of_memory+0x151/0x183
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848518]
[<ffffffff810b726b>] __alloc_pages_nodemask+0x550/0x6a1
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848527]
[<ffffffff810de22b>] alloc_pages_current+0xa8/0xd1
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848534]
[<ffffffff810b6284>] __get_free_pages+0x9/0x46
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848541]
[<ffffffff810fa893>] __pollwait+0x5e/0xcb
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848549]
[<ffffffff81258b37>] datagram_poll+0x23/0xcf
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848556]
[<ffffffff812a8457>] udp_poll+0x18/0x4d
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848562]
[<ffffffff8124d7ab>] sock_poll+0x18/0x1a
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848568]
[<ffffffff810fa17f>] do_select+0x3b2/0x5b9
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848576]
[<ffffffff810fa835>] ? __pollwait+0x0/0xcb
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848583]
[<ffffffff810fa900>] ? pollwake+0x0/0x5c
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848589]
[<ffffffff810fa900>] ? pollwake+0x0/0x5c
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848595]
[<ffffffff810fa900>] ? pollwake+0x0/0x5c
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848602]
[<ffffffff810fa900>] ? pollwake+0x0/0x5c
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848608]
[<ffffffff810fa900>] ? pollwake+0x0/0x5c
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848615]
[<ffffffff810fa900>] ? pollwake+0x0/0x5c
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848621]
[<ffffffff810fa900>] ? pollwake+0x0/0x5c
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848627]
[<ffffffff810fa900>] ? pollwake+0x0/0x5c
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848634]
[<ffffffff810fa900>] ? pollwake+0x0/0x5c
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848641]
[<ffffffff810fa529>] core_sys_select+0x1a3/0x251
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848649]
[<ffffffff81028556>] ? do_page_fault+0x2db/0x31a
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848657]
[<ffffffff8100ba65>] ? restore_i387_xstate+0x6e/0x168
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848665]
[<ffffffff810fa80d>] sys_select+0x94/0xbc
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848673]
[<ffffffff81002b42>] system_call_fastpath+0x16/0x1b
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848678] Mem-Info:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848681] Node 0 DMA per-cpu:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848687] CPU    0: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848692] CPU    1: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848696] CPU    2: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848700] CPU    3: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848705] CPU    4: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848709] CPU    5: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848713] Node 0 DMA32 per-cpu:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848718] CPU    0: hi:
186, btch:  31 usd: 155
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848723] CPU    1: hi:
186, btch:  31 usd:  93
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848727] CPU    2: hi:
186, btch:  31 usd: 163
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848731] CPU    3: hi:
186, btch:  31 usd: 139
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848736] CPU    4: hi:
186, btch:  31 usd: 173
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848740] CPU    5: hi:
186, btch:  31 usd: 158
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848743] Node 0 Normal per-cpu:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848748] CPU    0: hi:
186, btch:  31 usd: 168
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848753] CPU    1: hi:
186, btch:  31 usd: 124
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848757] CPU    2: hi:
186, btch:  31 usd:  75
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848761] CPU    3: hi:
186, btch:  31 usd:  47
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848765] CPU    4: hi:
186, btch:  31 usd:  67
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848770] CPU    5: hi:
186, btch:  31 usd: 136
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848780] active_anon:694172
inactive_anon:175990 isolated_anon:0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848783]  active_file:408
inactive_file:439 isolated_file:0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848786]  unevictable:1350
dirty:0 writeback:6 unstable:0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848788]  free:6263
slab_reclaimable:4511 slab_unreclaimable:8999
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848790]  mapped:942
shmem:24 pagetables:13273 bounce:0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848796] Node 0 DMA
free:15040kB min:28kB low:32kB high:40kB active_anon:336kB
inactive_anon:416kB active_file:0kB inactive_file:0kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:15688kB mlocked:0kB
dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
slab_unreclaimable:72kB kernel_stack:0kB pagetables:4kB unstable:0kB
bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848819] lowmem_reserve[]:
0 3254 3759 3759
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848826] Node 0 DMA32
free:8756kB min:6780kB low:8472kB high:10168kB active_anon:2591524kB
inactive_anon:518468kB active_file:252kB inactive_file:236kB
unevictable:2912kB isolated(anon):0kB isolated(file):0kB
present:3332768kB mlocked:2912kB dirty:0kB writeback:24kB mapped:204kB
shmem:68kB slab_reclaimable:10524kB slab_unreclaimable:20868kB
kernel_stack:1136kB pagetables:31772kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:768 all_unreclaimable? yes
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848851] lowmem_reserve[]:
0 0 505 505
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848857] Node 0 Normal
free:1256kB min:1052kB low:1312kB high:1576kB active_anon:184828kB
inactive_anon:185076kB active_file:1380kB inactive_file:1520kB
unevictable:2488kB isolated(anon):0kB isolated(file):0kB
present:517120kB mlocked:2488kB dirty:0kB writeback:0kB mapped:3564kB
shmem:28kB slab_reclaimable:7520kB slab_unreclaimable:15056kB
kernel_stack:1592kB pagetables:21316kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:4384 all_unreclaimable? yes
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848881] lowmem_reserve[]: 0 0 0 0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848887] Node 0 DMA: 2*4kB
3*8kB 2*16kB 2*32kB 3*64kB 1*128kB 1*256kB 0*512kB 2*1024kB 2*2048kB
2*4096kB = 15040kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848904] Node 0 DMA32:
1311*4kB 23*8kB 10*16kB 11*32kB 6*64kB 5*128kB 3*256kB 0*512kB
1*1024kB 0*2048kB 0*4096kB = 8756kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848924] Node 0 Normal:
302*4kB 6*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
0*2048kB 0*4096kB = 1256kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848941] 27025 total pagecache pages
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848944] 25453 pages in swap cache
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848949] Swap cache stats:
add 2328770, delete 2303317, find 790880/869989
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848953] Free swap  = 0kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.848956] Total swap = 5947388kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.881421] 983024 pages RAM
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.881425] 32468 pages reserved
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.881428] 28009 pages shared
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.881430] 941193 pages non-shared
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928261] gdm invoked
oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928271] gdm cpuset=/ mems_allowed=0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928279] Pid: 2470, comm:
gdm Not tainted 2.6.35.4 #1
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928283] Call Trace:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928297]
[<ffffffff810824f1>] ? cpuset_print_task_mems_allowed+0x8d/0x98
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928307]
[<ffffffff810b2e89>] dump_header+0x65/0x182
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928314]
[<ffffffff810b3237>] ? badness+0x157/0x216
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928323]
[<ffffffff8119031b>] ? ___ratelimit+0xc7/0xe4
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928330]
[<ffffffff810b2feb>] oom_kill_process+0x45/0x110
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928338]
[<ffffffff810b3439>] __out_of_memory+0x143/0x15a
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928345]
[<ffffffff810b35a1>] out_of_memory+0x151/0x183
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928353]
[<ffffffff810b726b>] __alloc_pages_nodemask+0x550/0x6a1
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928362]
[<ffffffff810de22b>] alloc_pages_current+0xa8/0xd1
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928369]
[<ffffffff810b108a>] __page_cache_alloc+0x77/0x82
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928377]
[<ffffffff810b88ce>] __do_page_cache_readahead+0x96/0x1a2
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928385]
[<ffffffff810b89f6>] ra_submit+0x1c/0x20
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928391]
[<ffffffff810b1582>] filemap_fault+0x1b0/0x31f
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928404]
[<ffffffff810c5e40>] __do_fault+0x50/0x413
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928412]
[<ffffffff810c8433>] handle_mm_fault+0x4d5/0x93e
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928419]
[<ffffffff810eb565>] ? do_sync_read+0xc7/0x10d
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928427]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928435]
[<ffffffff810917fc>] ? call_rcu_sched+0x10/0x12
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928442]
[<ffffffff81091807>] ? call_rcu+0x9/0xb
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928449]
[<ffffffff8106045e>] ? __put_cred+0x43/0x45
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928456]
[<ffffffff810606d3>] ? commit_creds+0x10f/0x119
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928465]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928469] Mem-Info:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928473] Node 0 DMA per-cpu:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928479] CPU    0: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928483] CPU    1: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928488] CPU    2: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928492] CPU    3: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928496] CPU    4: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928501] CPU    5: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928504] Node 0 DMA32 per-cpu:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928510] CPU    0: hi:
186, btch:  31 usd: 155
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928514] CPU    1: hi:
186, btch:  31 usd: 177
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928519] CPU    2: hi:
186, btch:  31 usd: 163
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928523] CPU    3: hi:
186, btch:  31 usd: 139
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928527] CPU    4: hi:
186, btch:  31 usd: 173
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928531] CPU    5: hi:
186, btch:  31 usd: 160
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928535] Node 0 Normal per-cpu:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928540] CPU    0: hi:
186, btch:  31 usd:  38
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928544] CPU    1: hi:
186, btch:  31 usd:  83
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928548] CPU    2: hi:
186, btch:  31 usd:  24
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928552] CPU    3: hi:
186, btch:  31 usd:  39
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928556] CPU    4: hi:
186, btch:  31 usd:  37
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928561] CPU    5: hi:
186, btch:  31 usd: 137
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928572] active_anon:694170
inactive_anon:175944 isolated_anon:64
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928574]  active_file:365
inactive_file:630 isolated_file:0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928577]  unevictable:1350
dirty:0 writeback:6 unstable:0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928579]  free:6170
slab_reclaimable:4511 slab_unreclaimable:8999
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928582]  mapped:948
shmem:24 pagetables:13273 bounce:0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928587] Node 0 DMA
free:15040kB min:28kB low:32kB high:40kB active_anon:336kB
inactive_anon:416kB active_file:0kB inactive_file:0kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:15688kB mlocked:0kB
dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
slab_unreclaimable:72kB kernel_stack:0kB pagetables:4kB unstable:0kB
bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928610] lowmem_reserve[]:
0 3254 3759 3759
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928618] Node 0 DMA32
free:8632kB min:6780kB low:8472kB high:10168kB active_anon:2591516kB
inactive_anon:518220kB active_file:80kB inactive_file:0kB
unevictable:2912kB isolated(anon):256kB isolated(file):0kB
present:3332768kB mlocked:2912kB dirty:0kB writeback:24kB mapped:212kB
shmem:68kB slab_reclaimable:10524kB slab_unreclaimable:20868kB
kernel_stack:1136kB pagetables:31772kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:16642 all_unreclaimable? yes
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928642] lowmem_reserve[]:
0 0 505 505
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928649] Node 0 Normal
free:1008kB min:1052kB low:1312kB high:1576kB active_anon:184828kB
inactive_anon:185140kB active_file:1380kB inactive_file:2556kB
unevictable:2488kB isolated(anon):0kB isolated(file):0kB
present:517120kB mlocked:2488kB dirty:0kB writeback:0kB mapped:3580kB
shmem:28kB slab_reclaimable:7520kB slab_unreclaimable:15056kB
kernel_stack:1592kB pagetables:21316kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:4384 all_unreclaimable? yes
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928673] lowmem_reserve[]: 0 0 0 0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928679] Node 0 DMA: 2*4kB
3*8kB 2*16kB 2*32kB 3*64kB 1*128kB 1*256kB 0*512kB 2*1024kB 2*2048kB
2*4096kB = 15040kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928696] Node 0 DMA32:
1311*4kB 23*8kB 11*16kB 11*32kB 6*64kB 5*128kB 3*256kB 0*512kB
1*1024kB 0*2048kB 0*4096kB = 8772kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928712] Node 0 Normal:
252*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
0*2048kB 0*4096kB = 1008kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928729] 27271 total pagecache pages
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928732] 25477 pages in swap cache
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928737] Swap cache stats:
add 2328796, delete 2303319, find 790882/869993
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928741] Free swap  = 0kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.928744] Total swap = 5947388kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.961130] 983024 pages RAM
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.961133] 32468 pages reserved
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.961136] 27963 pages shared
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.961139] 941277 pages non-shared
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964179] gdm invoked
oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964183] gdm cpuset=/ mems_allowed=0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964185] Pid: 2470, comm:
gdm Not tainted 2.6.35.4 #1
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964186] Call Trace:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964192]
[<ffffffff810824f1>] ? cpuset_print_task_mems_allowed+0x8d/0x98
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964195]
[<ffffffff810b2e89>] dump_header+0x65/0x182
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964199]
[<ffffffff8119031b>] ? ___ratelimit+0xc7/0xe4
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964201]
[<ffffffff810b2feb>] oom_kill_process+0x45/0x110
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964203]
[<ffffffff810b3439>] __out_of_memory+0x143/0x15a
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964205]
[<ffffffff810b35a1>] out_of_memory+0x151/0x183
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964207]
[<ffffffff810b726b>] __alloc_pages_nodemask+0x550/0x6a1
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964210]
[<ffffffff810de22b>] alloc_pages_current+0xa8/0xd1
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964213]
[<ffffffff810b108a>] __page_cache_alloc+0x77/0x82
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964215]
[<ffffffff810b88ce>] __do_page_cache_readahead+0x96/0x1a2
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964217]
[<ffffffff810b89f6>] ra_submit+0x1c/0x20
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964219]
[<ffffffff810b1582>] filemap_fault+0x1b0/0x31f
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964222]
[<ffffffff810c5e40>] __do_fault+0x50/0x413
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964224]
[<ffffffff810c8433>] handle_mm_fault+0x4d5/0x93e
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964227]
[<ffffffff810eb565>] ? do_sync_read+0xc7/0x10d
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964229]
[<ffffffff81028571>] do_page_fault+0x2f6/0x31a
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964232]
[<ffffffff810917fc>] ? call_rcu_sched+0x10/0x12
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964234]
[<ffffffff81091807>] ? call_rcu+0x9/0xb
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964236]
[<ffffffff8106045e>] ? __put_cred+0x43/0x45
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964238]
[<ffffffff810606d3>] ? commit_creds+0x10f/0x119
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964241]
[<ffffffff812e6fc5>] page_fault+0x25/0x30
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964242] Mem-Info:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964243] Node 0 DMA per-cpu:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964245] CPU    0: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964247] CPU    1: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964248] CPU    2: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964249] CPU    3: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964250] CPU    4: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964252] CPU    5: hi:
0, btch:   1 usd:   0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964253] Node 0 DMA32 per-cpu:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964254] CPU    0: hi:
186, btch:  31 usd: 155
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964256] CPU    1: hi:
186, btch:  31 usd: 177
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964257] CPU    2: hi:
186, btch:  31 usd: 163
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964258] CPU    3: hi:
186, btch:  31 usd: 139
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964259] CPU    4: hi:
186, btch:  31 usd: 173
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964261] CPU    5: hi:
186, btch:  31 usd: 160
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964262] Node 0 Normal per-cpu:
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964263] CPU    0: hi:
186, btch:  31 usd:  38
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964264] CPU    1: hi:
186, btch:  31 usd:  83
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964266] CPU    2: hi:
186, btch:  31 usd:  23
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964267] CPU    3: hi:
186, btch:  31 usd:  39
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964268] CPU    4: hi:
186, btch:  31 usd:  37
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964269] CPU    5: hi:
186, btch:  31 usd: 142
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964273] active_anon:694170
inactive_anon:175944 isolated_anon:64
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964273]  active_file:365
inactive_file:630 isolated_file:0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964274]  unevictable:1350
dirty:0 writeback:6 unstable:0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964275]  free:6170
slab_reclaimable:4511 slab_unreclaimable:8999
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964275]  mapped:948
shmem:24 pagetables:13273 bounce:0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964277] Node 0 DMA
free:15040kB min:28kB low:32kB high:40kB active_anon:336kB
inactive_anon:416kB active_file:0kB inactive_file:0kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:15688kB mlocked:0kB
dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
slab_unreclaimable:72kB kernel_stack:0kB pagetables:4kB unstable:0kB
bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964284] lowmem_reserve[]:
0 3254 3759 3759
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964286] Node 0 DMA32
free:8632kB min:6780kB low:8472kB high:10168kB active_anon:2591516kB
inactive_anon:518220kB active_file:80kB inactive_file:0kB
unevictable:2912kB isolated(anon):256kB isolated(file):0kB
present:3332768kB mlocked:2912kB dirty:0kB writeback:24kB mapped:212kB
shmem:68kB slab_reclaimable:10524kB slab_unreclaimable:20868kB
kernel_stack:1136kB pagetables:31772kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:16642 all_unreclaimable? yes
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964293] lowmem_reserve[]:
0 0 505 505
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964295] Node 0 Normal
free:1008kB min:1052kB low:1312kB high:1576kB active_anon:184828kB
inactive_anon:185140kB active_file:1380kB inactive_file:2556kB
unevictable:2488kB isolated(anon):0kB isolated(file):0kB
present:517120kB mlocked:2488kB dirty:0kB writeback:0kB mapped:3580kB
shmem:28kB slab_reclaimable:7520kB slab_unreclaimable:15056kB
kernel_stack:1592kB pagetables:21316kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:4384 all_unreclaimable? yes
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964302] lowmem_reserve[]: 0 0 0 0
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964303] Node 0 DMA: 2*4kB
3*8kB 2*16kB 2*32kB 3*64kB 1*128kB 1*256kB 0*512kB 2*1024kB 2*2048kB
2*4096kB = 15040kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964308] Node 0 DMA32:
1311*4kB 23*8kB 11*16kB 11*32kB 6*64kB 5*128kB 3*256kB 0*512kB
1*1024kB 0*2048kB 0*4096kB = 8772kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964313] Node 0 Normal:
252*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
0*2048kB 0*4096kB = 1008kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964318] 27271 total pagecache pages
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964319] 25477 pages in swap cache
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964320] Swap cache stats:
add 2328796, delete 2303319, find 790882/869994
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964322] Free swap  = 0kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.964322] Total swap = 5947388kB
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.976647] 983024 pages RAM
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.976648] 32468 pages reserved
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.976649] 27964 pages shared
Sep 21 22:42:46 RANDOMBOXEN kernel: [329456.976649] 941277 pages non-shared

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
