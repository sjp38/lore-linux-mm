Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 57B1E6B012D
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 02:19:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4D4C13EE081
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 15:19:32 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 37ABA45DE50
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 15:19:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 221EE45DE4E
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 15:19:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 13159E08002
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 15:19:32 +0900 (JST)
Received: from g01jpexchyt02.g01.fujitsu.local (g01jpexchyt02.g01.fujitsu.local [10.128.194.41])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B188D1DB8037
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 15:19:31 +0900 (JST)
Message-ID: <50517ADF.70201@jp.fujitsu.com>
Date: Thu, 13 Sep 2012 15:19:11 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: memory-hotplug : possible circular locking dependency detected
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

When I offline a memory on linux-3.6-rc5, "possible circular
locking dependency detected" messages are shown.
Are the messages known problem?

[  201.596363] Offlined Pages 32768
[  201.596373] remove from free list 140000 1024 148000
[  201.596493] remove from free list 140400 1024 148000
[  201.596612] remove from free list 140800 1024 148000
[  201.596730] remove from free list 140c00 1024 148000
[  201.596849] remove from free list 141000 1024 148000
[  201.596968] remove from free list 141400 1024 148000
[  201.597049] remove from free list 141800 1024 148000
[  201.597049] remove from free list 141c00 1024 148000
[  201.597049] remove from free list 142000 1024 148000
[  201.597049] remove from free list 142400 1024 148000
[  201.597049] remove from free list 142800 1024 148000
[  201.597049] remove from free list 142c00 1024 148000
[  201.597049] remove from free list 143000 1024 148000
[  201.597049] remove from free list 143400 1024 148000
[  201.597049] remove from free list 143800 1024 148000
[  201.597049] remove from free list 143c00 1024 148000
[  201.597049] remove from free list 144000 1024 148000
[  201.597049] remove from free list 144400 1024 148000
[  201.597049] remove from free list 144800 1024 148000
[  201.597049] remove from free list 144c00 1024 148000
[  201.597049] remove from free list 145000 1024 148000
[  201.597049] remove from free list 145400 1024 148000
[  201.597049] remove from free list 145800 1024 148000
[  201.597049] remove from free list 145c00 1024 148000
[  201.597049] remove from free list 146000 1024 148000
[  201.597049] remove from free list 146400 1024 148000
[  201.597049] remove from free list 146800 1024 148000
[  201.597049] remove from free list 146c00 1024 148000
[  201.597049] remove from free list 147000 1024 148000
[  201.597049] remove from free list 147400 1024 148000
[  201.597049] remove from free list 147800 1024 148000
[  201.597049] remove from free list 147c00 1024 148000
[  201.602143] 
[  201.602150] ======================================================
[  201.602153] [ INFO: possible circular locking dependency detected ]
[  201.602157] 3.6.0-rc5 #1 Not tainted
[  201.602159] -------------------------------------------------------
[  201.602162] bash/2789 is trying to acquire lock:
[  201.602164]  ((memory_chain).rwsem){.+.+.+}, at: [<ffffffff8109fe16>] __blocking_notifier_call_chain+0x66/0xd0
[  201.602180] 
[  201.602180] but task is already holding lock:
[  201.602182]  (ksm_thread_mutex/1){+.+.+.}, at: [<ffffffff811b41fa>] ksm_memory_callback+0x3a/0xc0
[  201.602194] 
[  201.602194] which lock already depends on the new lock.
[  201.602194] 
[  201.602197] 
[  201.602197] the existing dependency chain (in reverse order) is:
[  201.602200] 
[  201.602200] -> #1 (ksm_thread_mutex/1){+.+.+.}:
[  201.602208]        [<ffffffff810dbee9>] validate_chain+0x6d9/0x7e0
[  201.602214]        [<ffffffff810dc2e6>] __lock_acquire+0x2f6/0x4f0
[  201.602219]        [<ffffffff810dc57d>] lock_acquire+0x9d/0x190
[  201.602223]        [<ffffffff8166b4fc>] __mutex_lock_common+0x5c/0x420
[  201.602229]        [<ffffffff8166ba2a>] mutex_lock_nested+0x4a/0x60
[  201.602234]        [<ffffffff811b41fa>] ksm_memory_callback+0x3a/0xc0
[  201.602239]        [<ffffffff81673447>] notifier_call_chain+0x67/0x150
[  201.602244]        [<ffffffff8109fe2b>] __blocking_notifier_call_chain+0x7b/0xd0
[  201.602250]        [<ffffffff8109fe96>] blocking_notifier_call_chain+0x16/0x20
[  201.602255]        [<ffffffff8144c53b>] memory_notify+0x1b/0x20
[  201.602261]        [<ffffffff81653c51>] offline_pages+0x1b1/0x470
[  201.602267]        [<ffffffff811bfcae>] remove_memory+0x1e/0x20
[  201.602273]        [<ffffffff8144c661>] memory_block_action+0xa1/0x190
[  201.602278]        [<ffffffff8144c7c9>] memory_block_change_state+0x79/0xe0
[  201.602282]        [<ffffffff8144c8f2>] store_mem_state+0xc2/0xd0
[  201.602287]        [<ffffffff81436980>] dev_attr_store+0x20/0x30
[  201.602293]        [<ffffffff812498d3>] sysfs_write_file+0xa3/0x100
[  201.602299]        [<ffffffff811cba80>] vfs_write+0xd0/0x1a0
[  201.602304]        [<ffffffff811cbc54>] sys_write+0x54/0xa0
[  201.602309]        [<ffffffff81678529>] system_call_fastpath+0x16/0x1b
[  201.602315] 
[  201.602315] -> #0 ((memory_chain).rwsem){.+.+.+}:
[  201.602322]        [<ffffffff810db7e7>] check_prev_add+0x527/0x550
[  201.602326]        [<ffffffff810dbee9>] validate_chain+0x6d9/0x7e0
[  201.602331]        [<ffffffff810dc2e6>] __lock_acquire+0x2f6/0x4f0
[  201.602335]        [<ffffffff810dc57d>] lock_acquire+0x9d/0x190
[  201.602340]        [<ffffffff8166c1a1>] down_read+0x51/0xa0
[  201.602345]        [<ffffffff8109fe16>] __blocking_notifier_call_chain+0x66/0xd0
[  201.602350]        [<ffffffff8109fe96>] blocking_notifier_call_chain+0x16/0x20
[  201.602355]        [<ffffffff8144c53b>] memory_notify+0x1b/0x20
[  201.602360]        [<ffffffff81653e67>] offline_pages+0x3c7/0x470
[  201.602365]        [<ffffffff811bfcae>] remove_memory+0x1e/0x20
[  201.602370]        [<ffffffff8144c661>] memory_block_action+0xa1/0x190
[  201.602375]        [<ffffffff8144c7c9>] memory_block_change_state+0x79/0xe0
[  201.602379]        [<ffffffff8144c8f2>] store_mem_state+0xc2/0xd0
[  201.602385]        [<ffffffff81436980>] dev_attr_store+0x20/0x30
[  201.602389]        [<ffffffff812498d3>] sysfs_write_file+0xa3/0x100
[  201.602394]        [<ffffffff811cba80>] vfs_write+0xd0/0x1a0
[  201.602398]        [<ffffffff811cbc54>] sys_write+0x54/0xa0
[  201.602403]        [<ffffffff81678529>] system_call_fastpath+0x16/0x1b
[  201.602408] 
[  201.602408] other info that might help us debug this:
[  201.602408] 
[  201.602412]  Possible unsafe locking scenario:
[  201.602412] 
[  201.602414]        CPU0                    CPU1
[  201.602417]        ----                    ----
[  201.602419]   lock(ksm_thread_mutex/1);
[  201.602425]                                lock((memory_chain).rwsem);
[  201.602430]                                lock(ksm_thread_mutex/1);
[  201.602435]   lock((memory_chain).rwsem);
[  201.602440] 
[  201.602440]  *** DEADLOCK ***
[  201.602440] 
[  201.602444] 6 locks held by bash/2789:
[  201.602446]  #0:  (&buffer->mutex){+.+.+.}, at: [<ffffffff81249879>] sysfs_write_file+0x49/0x100
[  201.602456]  #1:  (s_active#212){.+.+.+}, at: [<ffffffff812498b7>] sysfs_write_file+0x87/0x100
[  201.602467]  #2:  (&mem->state_mutex){+.+.+.}, at: [<ffffffff8144c78e>] memory_block_change_state+0x3e/0xe0
[  201.602477]  #3:  (mem_hotplug_mutex){+.+.+.}, at: [<ffffffff811bf867>] lock_memory_hotplug+0x17/0x40
[  201.602487]  #4:  (pm_mutex){+.+.+.}, at: [<ffffffff811bf885>] lock_memory_hotplug+0x35/0x40
[  201.602497]  #5:  (ksm_thread_mutex/1){+.+.+.}, at: [<ffffffff811b41fa>] ksm_memory_callback+0x3a/0xc0
[  201.602508] 
[  201.602508] stack backtrace:
[  201.602512] Pid: 2789, comm: bash Not tainted 3.6.0-rc5 #1
[  201.602515] Call Trace:
[  201.602522]  [<ffffffff810da119>] print_circular_bug+0x109/0x110
[  201.602527]  [<ffffffff810db7e7>] check_prev_add+0x527/0x550
[  201.602532]  [<ffffffff810dbee9>] validate_chain+0x6d9/0x7e0
[  201.602537]  [<ffffffff810dc2e6>] __lock_acquire+0x2f6/0x4f0
[  201.602543]  [<ffffffff8101f7c3>] ? native_sched_clock+0x13/0x80
[  201.602547]  [<ffffffff810dc57d>] lock_acquire+0x9d/0x190
[  201.602553]  [<ffffffff8109fe16>] ? __blocking_notifier_call_chain+0x66/0xd0
[  201.602558]  [<ffffffff8166c1a1>] down_read+0x51/0xa0
[  201.602563]  [<ffffffff8109fe16>] ? __blocking_notifier_call_chain+0x66/0xd0
[  201.602569]  [<ffffffff8109fe16>] __blocking_notifier_call_chain+0x66/0xd0
[  201.602574]  [<ffffffff81186dc6>] ? next_online_pgdat+0x26/0x50
[  201.602580]  [<ffffffff8109fe96>] blocking_notifier_call_chain+0x16/0x20
[  201.602585]  [<ffffffff8144c53b>] memory_notify+0x1b/0x20
[  201.602590]  [<ffffffff81653e67>] offline_pages+0x3c7/0x470
[  201.602596]  [<ffffffff811bfcae>] remove_memory+0x1e/0x20
[  201.602601]  [<ffffffff8144c661>] memory_block_action+0xa1/0x190
[  201.602606]  [<ffffffff8166ba2a>] ? mutex_lock_nested+0x4a/0x60
[  201.602611]  [<ffffffff8144c7c9>] memory_block_change_state+0x79/0xe0
[  201.602617]  [<ffffffff8118f3ec>] ? might_fault+0x5c/0xb0
[  201.602622]  [<ffffffff8144c8f2>] store_mem_state+0xc2/0xd0
[  201.602627]  [<ffffffff812498b7>] ? sysfs_write_file+0x87/0x100
[  201.602632]  [<ffffffff81436980>] dev_attr_store+0x20/0x30
[  201.602636]  [<ffffffff812498d3>] sysfs_write_file+0xa3/0x100
[  201.602641]  [<ffffffff811cba80>] vfs_write+0xd0/0x1a0
[  201.602646]  [<ffffffff811cbc54>] sys_write+0x54/0xa0
[  201.602652]  [<ffffffff81678529>] system_call_fastpath+0x16/0x1b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
