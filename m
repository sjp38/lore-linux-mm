Received: by gxk6 with SMTP id 6so244619gxk.14
        for <linux-mm@kvack.org>; Thu, 13 Nov 2008 04:56:37 -0800 (PST)
Message-ID: <a4423d670811130456mf60422exf8d7b9b08aede03e@mail.gmail.com>
Date: Thu, 13 Nov 2008 15:56:37 +0300
From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: Deadlock at io_schedule? (Re: linux-next: Tree for November 3)
In-Reply-To: <a4423d670811030533x62af4599mb0ecf33f91f070ed@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <a4423d670811030533x62af4599mb0ecf33f91f070ed@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

2008/11/3 Alexander Beregalov <a.beregalov@gmail.com>:
> Hi
>
> 2.6.28-rc3-next-20081103 on sparc64

The same on SMP x86_64, 2.6.28-rc4-next-20081113
Please have a look anybody


[ 5383.663175] Showing all locks held in the system:
[ 5383.663187] 1 lock held by agetty/1958:
[ 5383.663190]  #0:  (&tty->atomic_read_lock){--..}, at:
[<ffffffff80400ded>] n_tty_read+0x29b/0x7bd
[ 5383.663203] 1 lock held by agetty/1959:
[ 5383.663205]  #0:  (&tty->atomic_read_lock){--..}, at:
[<ffffffff80400ded>] n_tty_read+0x29b/0x7bd
[ 5383.663214] 1 lock held by agetty/1960:
[ 5383.663216]  #0:  (&tty->atomic_read_lock){--..}, at:
[<ffffffff80400ded>] n_tty_read+0x29b/0x7bd
[ 5383.663224] 1 lock held by agetty/1963:
[ 5383.663226]  #0:  (&tty->atomic_read_lock){--..}, at:
[<ffffffff80400ded>] n_tty_read+0x29b/0x7bd
[ 5383.663234] 1 lock held by agetty/1964:
[ 5383.663236]  #0:  (&tty->atomic_read_lock){--..}, at:
[<ffffffff80400ded>] n_tty_read+0x29b/0x7bd
[ 5383.663244] 1 lock held by agetty/1966:
[ 5383.663246]  #0:  (&tty->atomic_read_lock){--..}, at:
[<ffffffff80400ded>] n_tty_read+0x29b/0x7bd
[ 5383.663255] 2 locks held by bash/2011:
[ 5383.663257]  #0:  (sysrq_key_table_lock){....}, at:
[<ffffffff804102fb>] __handle_sysrq+0x26/0x158
[ 5383.663264]  #1:  (tasklist_lock){..--}, at: [<ffffffff802569d8>]
debug_show_all_locks+0x4d/0x17f
[ 5383.663274] 1 lock held by bash/2028:
[ 5383.663276]  #0:  (&(&ip->i_iolock)->mr_lock){----}, at:
[<ffffffff8037646b>] xfs_ilock+0x44/0x79
[ 5383.663285]
[ 5383.663287] =============================================
[ 5383.663288]
[ 5394.063573] SysRq : Show Blocked State
[ 5394.063608]   task                        PC stack   pid father
[ 5394.063624] pdflush       D ffff880004d9a740  3256   313      2
[ 5394.063631]  ffff88007d265d50 0000000000000046 ffff88007dac4a80
ffff88007dac4a80
[ 5394.063638]  ffffffff80930740 ffffffff80930740 ffff88007dac4a80
ffff88007d8092a0
[ 5394.063645]  ffff88007dac4dc8 0000000180231acf ffff88007d265ce0
ffff88007dac4dc8
[ 5394.063652] Call Trace:
[ 5394.063661]  [<ffffffff8052792b>] ? _spin_unlock_irqrestore+0x66/0x74
[ 5394.063667]  [<ffffffff80240834>] ? __mod_timer+0xd3/0xe5
[ 5394.063671]  [<ffffffff80525c34>] schedule_timeout+0x8d/0xb4
[ 5394.063675]  [<ffffffff802401cb>] ? process_timeout+0x0/0xb
[ 5394.063679]  [<ffffffff8024077e>] ? __mod_timer+0x1d/0xe5
[ 5394.063683]  [<ffffffff80524f75>] __sched_text_start+0x2d/0x39
[ 5394.063688]  [<ffffffff80282c15>] congestion_wait+0x6b/0x87
[ 5394.063692]  [<ffffffff8024a5db>] ? autoremove_wake_function+0x0/0x38
[ 5394.063697]  [<ffffffff802b80f8>] ? writeback_inodes+0xec/0xf4
[ 5394.063702]  [<ffffffff8027bc65>] wb_kupdate+0xc4/0x11e
[ 5394.063706]  [<ffffffff8027c6bf>] pdflush+0x11a/0x1cd
[ 5394.063710]  [<ffffffff8027bba1>] ? wb_kupdate+0x0/0x11e
[ 5394.063713]  [<ffffffff8027c5a5>] ? pdflush+0x0/0x1cd
[ 5394.063717]  [<ffffffff8024a1e9>] kthread+0x49/0x76
[ 5394.063722]  [<ffffffff8020c8a9>] child_rip+0xa/0x11
[ 5394.063727]  [<ffffffff80231966>] ? finish_task_switch+0x0/0xb9
[ 5394.063730]  [<ffffffff8020bd98>] ? restore_args+0x0/0x30
[ 5394.063734]  [<ffffffff8024a1a0>] ? kthread+0x0/0x76
[ 5394.063737]  [<ffffffff8020c89f>] ? child_rip+0x0/0x11
[ 5394.063741] xfsbufd       D ffff880005138740  6032   695      2
[ 5394.063748]  ffff88007cf35c80 0000000000000046 ffff88007cf35bf0
ffffffff80255c61
[ 5394.063754]  ffffffff80930740 ffffffff80930740 ffff88007cf70000
ffff88007dfa4a80
[ 5394.063760]  ffff88007cf70348 0000000380255c61 ffff88007cf70000
ffff88007cf70348
[ 5394.063765] Call Trace:
[ 5394.063770]  [<ffffffff80255c61>] ? get_lock_stats+0x2d/0x5c
[ 5394.063773]  [<ffffffff80255c9e>] ? put_lock_stats+0xe/0x27
[ 5394.063777]  [<ffffffff802300af>] ? get_parent_ip+0x11/0x41
[ 5394.063781]  [<ffffffff80525a88>] io_schedule+0x2d/0x39
[ 5394.063786]  [<ffffffff803a8cec>] get_request_wait+0x10a/0x1a6
[ 5394.063790]  [<ffffffff8024a5db>] ? autoremove_wake_function+0x0/0x38
[ 5394.063794]  [<ffffffff803a51c5>] ? elv_merge+0x16d/0x19e
[ 5394.063798]  [<ffffffff803a913b>] __make_request+0x3b3/0x4b1
[ 5394.063802]  [<ffffffff80277502>] ? mempool_alloc+0x56/0x10e
[ 5394.063806]  [<ffffffff803a792c>] generic_make_request+0x2f4/0x337
[ 5394.063810]  [<ffffffff80231acf>] ? sub_preempt_count+0xb0/0xc4
[ 5394.063813]  [<ffffffff803a7a08>] submit_bio+0x99/0xa2
[ 5394.063818]  [<ffffffff803939fa>] _xfs_buf_ioapply+0x215/0x243
[ 5394.063822]  [<ffffffff8039477d>] xfs_buf_iorequest+0x44/0x75
[ 5394.063826]  [<ffffffff803983c7>] xfs_bdstrat_cb+0x19/0x3e
[ 5394.063830]  [<ffffffff803947c0>] xfs_buf_iostrategy+0x12/0x1b
[ 5394.063833]  [<ffffffff803949e6>] xfsbufd+0xa8/0xe9
[ 5394.063837]  [<ffffffff8039493e>] ? xfsbufd+0x0/0xe9
[ 5394.063840]  [<ffffffff8024a1e9>] kthread+0x49/0x76
[ 5394.063844]  [<ffffffff8020c8a9>] child_rip+0xa/0x11
[ 5394.063848]  [<ffffffff80231966>] ? finish_task_switch+0x0/0xb9
[ 5394.063856]  [<ffffffff8020bd98>] ? restore_args+0x0/0x30
[ 5394.063858]  [<ffffffff8024a1a0>] ? kthread+0x0/0x76
[ 5394.063861]  [<ffffffff8020c89f>] ? child_rip+0x0/0x11
[ 5394.063863] bash          D ffff880004d9a740  5240  2028   2015
[ 5394.063868]  ffff8800730f1a88 0000000000000046 0000000000000001
ffff88007ca26430
[ 5394.063872]  ffffffff80930740 ffffffff80930740 ffff88007ca25d20
ffff88007df62540
[ 5394.063876]  ffff88007ca26068 0000000180aacde0 ffff8800730f1a38
ffff88007ca26068
[ 5394.063880] Call Trace:
[ 5394.063883]  [<ffffffff803a8721>] ? generic_unplug_device+0x1d/0x46
[ 5394.063885]  [<ffffffff80525a88>] io_schedule+0x2d/0x39
[ 5394.063888]  [<ffffffff80275742>] sync_page+0x69/0x70
[ 5394.063890]  [<ffffffff80275757>] sync_page_killable+0xe/0x46
[ 5394.063893]  [<ffffffff80525cf1>] __wait_on_bit_lock+0x45/0x79
[ 5394.063895]  [<ffffffff80275749>] ? sync_page_killable+0x0/0x46
[ 5394.063897]  [<ffffffff802755ed>] __lock_page_killable+0x63/0x6a
[ 5394.063900]  [<ffffffff8024a613>] ? wake_bit_function+0x0/0x2a
[ 5394.063902]  [<ffffffff80275510>] ? find_get_page+0x75/0x85
[ 5394.063905]  [<ffffffff80275626>] lock_page_killable+0x32/0x3a
[ 5394.063907]  [<ffffffff80276de8>] generic_file_aio_read+0x39d/0x581
[ 5394.063910]  [<ffffffff8037646b>] ? xfs_ilock+0x44/0x79
[ 5394.063913]  [<ffffffff80399285>] xfs_read+0x17b/0x1f2
[ 5394.063915]  [<ffffffff8039576a>] xfs_file_aio_read+0x51/0x53
[ 5394.063919]  [<ffffffff8029e678>] do_sync_read+0xe7/0x12d
[ 5394.063921]  [<ffffffff80231acf>] ? sub_preempt_count+0xb0/0xc4
[ 5394.063924]  [<ffffffff8024a5db>] ? autoremove_wake_function+0x0/0x38
[ 5394.063926]  [<ffffffff80255d69>] ? lock_release_holdtime+0xb2/0xb7
[ 5394.063929]  [<ffffffff8029ef37>] vfs_read+0xa4/0xde
[ 5394.063932]  [<ffffffff802a3692>] kernel_read+0x43/0x5b
[ 5394.063935]  [<ffffffff80283f31>] ? might_fault+0x4d/0xa1
[ 5394.063937]  [<ffffffff802a3787>] prepare_binprm+0xdd/0xe1
[ 5394.063939]  [<ffffffff802a3ddc>] do_execve+0xde/0x1da
[ 5394.063942]  [<ffffffff80209ce6>] sys_execve+0x3e/0x60
[ 5394.063944]  [<ffffffff8020bb8a>] stub_execve+0x6a/0xc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
