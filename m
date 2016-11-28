Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4AAC6B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:16:38 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id b14so58923019lfg.6
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:16:38 -0800 (PST)
Received: from mail.setcomm.ru (mail.setcomm.ru. [2a00:1248:5004:5::3])
        by mx.google.com with ESMTP id o203si19886062lfo.109.2016.11.28.11.16.37
        for <linux-mm@kvack.org>;
        Mon, 28 Nov 2016 11:16:37 -0800 (PST)
Reply-To: bb@kernelpanic.ru
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
References: <d6981bac-8e97-b482-98c0-40949db03ca3@kernelpanic.ru>
 <20161124133019.GE3612@linux.vnet.ibm.com>
 <de88a72a-f861-b51f-9fb3-4265378702f1@kernelpanic.ru>
 <20161125212000.GI31360@linux.vnet.ibm.com>
 <20161128095825.GI14788@dhcp22.suse.cz>
 <20161128105425.GY31360@linux.vnet.ibm.com>
 <3a4242cb-0198-0a3b-97ae-536fb5ff83ec@kernelpanic.ru>
 <20161128143435.GC3924@linux.vnet.ibm.com>
 <eba1571e-f7a8-09b3-5516-c2bc35b38a83@kernelpanic.ru>
 <20161128150509.GG3924@linux.vnet.ibm.com>
From: Boris Zhmurov <bb@kernelpanic.ru>
Message-ID: <f9c76351-56a6-466d-98c0-b821c2b54a3d@kernelpanic.ru>
Date: Mon, 28 Nov 2016 22:16:33 +0300
MIME-Version: 1.0
In-Reply-To: <20161128150509.GG3924@linux.vnet.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------91418DD43DD45B74C039CF90"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Michal Hocko <mhocko@kernel.org>, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------91418DD43DD45B74C039CF90
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

Paul E. McKenney 28/11/16 18:05:
> On Mon, Nov 28, 2016 at 05:40:48PM +0300, Boris Zhmurov wrote:
>> Paul E. McKenney 28/11/16 17:34:
>>
>>
>>>> So Paul, I've dropped "mm: Prevent shrink_node_memcg() RCU CPU stall
>>>> warnings" patch, and stalls got back (attached).
>>>>
>>>> With this patch "commit 7cebc6b63bf75db48cb19a94564c39294fd40959" from
>>>> your tree stalls gone. Looks like that.
>>>
>>> So with only this commit and no other commit or configuration adjustment,
>>> everything works?  Or it the solution this commit and some other stuff?
>>>
>>> The reason I ask is that if just this commit does the trick, I should
>>> drop the others.
>>
>> I'd like to ask for some more time to make sure this is it.
>> Approximately 2 or 3 days.
> 
> Works for me!
> 
> 							Thanx, Paul


FYI.
Some more stalls with mm-prevent-shrink_node-RCU-CPU-stall-warning.patch
and without mm-prevent-shrink_node_memcg-RCU-CPU-stall-warnings.patch.


-- 
Boris Zhmurov
System/Network Administrator
mailto: bb@kernelpanic.ru
"wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"

--------------91418DD43DD45B74C039CF90
Content-Type: text/plain; charset=UTF-8;
 name="rcustall-5.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rcustall-5.txt"

[26327.859412] INFO: rcu_sched detected stalls on CPUs/tasks:
[26327.859466] 	18-...: (39 ticks this GP) idle=1ed/140000000000000/0 softirq=3790251/3790251 fqs=24 
[26327.859529] 	(detected by 2, t=6429 jiffies, g=1258488, c=1258487, q=6044)
[26327.859583] Task dump for CPU 18:
[26327.859584] kswapd1         R  running task        0   148      2 0x00000008
[26327.859588]  ffff9e779f411400 ffff9e779096fe68 ffff9e8fffffc000 0000000000000000
[26327.859591]  ffffffffa592404d 0000000000000000 0000000000000000 0000000000000000
[26327.859593]  0000000000000000 ffff9e779096fe58 000000000170bf2c ffff9e8fffffc000
[26327.859596] Call Trace:
[26327.859604]  [<ffffffffa592404d>] ? shrink_node+0xcd/0x2f0
[26327.859606]  [<ffffffffa5924cca>] ? kswapd+0x2ba/0x5e0
[26327.859609]  [<ffffffffa5924a10>] ? mem_cgroup_shrink_node+0x90/0x90
[26327.859612]  [<ffffffffa587bce8>] ? kthread+0xb8/0xd0
[26327.859616]  [<ffffffffa5d1311f>] ? ret_from_fork+0x1f/0x40
[26327.859618]  [<ffffffffa587bc30>] ? kthread_create_on_node+0x170/0x170
[26351.132731] INFO: rcu_sched detected stalls on CPUs/tasks:
[26351.132778] 	(detected by 2, t=6432 jiffies, g=1258490, c=1258489, q=7476)
[26351.132835] All QSes seen, last rcu_sched kthread activity 1405 (4302782902-4302781497), jiffies_till_next_fqs=2, root ->qsmask 0x0
[26351.132917] mc:writer_9     R  running task        0 28495   2101 0x00000008
[26351.132921]  ffffffffa623e600 ffffffffa58b5337 0000000000000000 0000000000000000
[26351.132923]  0000000000001d34 ffffffffa623e600 ffffffffa58be772 ffff9e8c0e54f300
[26351.132925]  0000000000000000 ffff9e78027ffb08 000017f78e9681f9 0000000000000001
[26351.132928] Call Trace:
[26351.132929]  <IRQ>  [<ffffffffa58b5337>] ? rcu_check_callbacks+0x727/0x730
[26351.132939]  [<ffffffffa58be772>] ? update_wall_time+0x382/0x710
[26351.132942]  [<ffffffffa58b8093>] ? update_process_times+0x23/0x50
[26351.132947]  [<ffffffffa58c5bad>] ? tick_sched_handle.isra.15+0x2d/0x40
[26351.132949]  [<ffffffffa58c5bf3>] ? tick_sched_timer+0x33/0x60
[26351.132950]  [<ffffffffa58b879d>] ? __hrtimer_run_queues+0x9d/0x110
[26351.132952]  [<ffffffffa58b8cb4>] ? hrtimer_interrupt+0x94/0x190
[26351.132957]  [<ffffffffa5842b74>] ? smp_apic_timer_interrupt+0x34/0x50
[26351.132961]  [<ffffffffa5d13a82>] ? apic_timer_interrupt+0x82/0x90
[26351.132961]  <EOI>  [<ffffffffa5d12b2c>] ? _raw_spin_unlock_irqrestore+0xc/0x20
[26351.132968]  [<ffffffffa591d8fb>] ? pagevec_lru_move_fn+0xab/0xe0
[26351.132969]  [<ffffffffa591cee0>] ? SyS_readahead+0x90/0x90
[26351.132971]  [<ffffffffa591d9bc>] ? __lru_cache_add+0x4c/0x60
[26351.132974]  [<ffffffffa590efa9>] ? add_to_page_cache_lru+0x59/0xc0
[26351.132976]  [<ffffffffa590f89b>] ? pagecache_get_page+0xcb/0x240
[26351.132979]  [<ffffffffa591096d>] ? grab_cache_page_write_begin+0x1d/0x40
[26351.132998]  [<ffffffffc028c3db>] ? ext4_da_write_begin+0x9b/0x330 [ext4]
[26351.133000]  [<ffffffffa5910afe>] ? generic_perform_write+0xbe/0x1a0
[26351.133003]  [<ffffffffa5998126>] ? file_update_time+0x36/0xe0
[26351.133005]  [<ffffffffa59116b0>] ? __generic_file_write_iter+0x170/0x1d0
[26351.133012]  [<ffffffffc0281d4b>] ? ext4_file_write_iter+0x11b/0x320 [ext4]
[26351.133015]  [<ffffffffa588e4ae>] ? set_next_entity+0x6e/0x770
[26351.133017]  [<ffffffffa588d9ab>] ? put_prev_entity+0x5b/0x6f0
[26351.133019]  [<ffffffffa597ea21>] ? __vfs_write+0xc1/0x120
[26351.133021]  [<ffffffffa597f5c8>] ? vfs_write+0xa8/0x1a0
[26351.133023]  [<ffffffffa598084d>] ? SyS_write+0x3d/0xa0
[26351.133025]  [<ffffffffa5d12ef6>] ? entry_SYSCALL_64_fastpath+0x1e/0xa8
[26351.133027] rcu_sched kthread starved for 1405 jiffies! g1258490 c1258489 f0x2 RCU_GP_WAIT_FQS(3) ->state=0x0
[26351.133097] rcu_sched       R  running task        0     8      2 0x00000000
[26351.133099]  ffff9e7792d45080 0000000000000246 ffff9e7792da0000 ffff9e7792d9fe60
[26351.133102]  0000000100773c3b ffff9e7792d9fe00 ffff9e779fc0fa00 0000000100773c39
[26351.133104]  ffffffffa5d0fc8c ffff9e779fc0fa00 ffffffffa5d122b7 0000000ea58817f6
[26351.133107] Call Trace:
[26351.133112]  [<ffffffffa5d0fc8c>] ? schedule+0x2c/0x80
[26351.133114]  [<ffffffffa5d122b7>] ? schedule_timeout+0x127/0x240
[26351.133116]  [<ffffffffa58b7500>] ? del_timer_sync+0x50/0x50
[26351.133119]  [<ffffffffa58b448a>] ? rcu_gp_kthread+0x37a/0x860
[26351.133121]  [<ffffffffa58b4110>] ? force_qs_rnp+0x180/0x180
[26351.133124]  [<ffffffffa587bce8>] ? kthread+0xb8/0xd0
[26351.133126]  [<ffffffffa5d1311f>] ? ret_from_fork+0x1f/0x40
[26351.133128]  [<ffffffffa587bc30>] ? kthread_create_on_node+0x170/0x170

--------------91418DD43DD45B74C039CF90--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
