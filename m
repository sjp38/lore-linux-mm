Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4219B6B0266
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:25:55 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x23so17270087pgx.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:25:55 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id y3si31992330pgo.229.2016.12.08.21.25.50
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:25:51 -0800 (PST)
Date: Fri, 9 Dec 2016 14:21:28 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: [FYI] Output of 'cat /proc/lockdep' after applying crossrelease
Message-ID: <20161209052128.GQ2279@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com


all lock classes:
c1c8b858 FD:   38 BD:    1 +.+...: cgroup_mutex
 -> [c1c8b7b0] cgroup_idr_lock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1c8b770] cgroup_file_kn_lock
 -> [c1c8b7f0] css_set_lock
 -> [c1c8bbb8] freezer_mutex

c1cd86c8 FD:    1 BD:  104 -.-...: input_pool.lock

c1cd85c8 FD:    1 BD:  103 ..-...: nonblocking_pool.lock

c1c80634 FD:    2 BD:   16 ++++..: resource_lock
 -> [c1c805f0] bootmem_resource_lock

c1c7f3f0 FD:    1 BD:   21 +.+...: pgd_lock

c1c7e1d8 FD:   12 BD:    1 +.+...: acpi_ioapic_lock
 -> [c1c7e6d0] ioapic_lock
 -> [c1c7e698] ioapic_mutex

c1c7e6d0 FD:    2 BD:   71 -.-...: ioapic_lock
 -> [c1c7bdb0] i8259A_lock

c1cf63d0 FD:    1 BD:    1 ......: map_entries_lock

c1c7d7b0 FD:    1 BD:    1 ......: x86_mce_decoder_chain.lock

c1c89db8 FD:   44 BD:    2 +.+...: clocksource_mutex
 -> [c1c89d10] watchdog_lock

c1c89d10 FD:    9 BD:    4 +.-...: watchdog_lock
 -> [c259f24c] &(&base->lock)->rlock
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1c7ff18 FD:  172 BD:    2 +.+.+.: cpu_add_remove_lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25bc6b4] &swhash->hlist_mutex
 -> [c1c7fec0] cpu_hotplug.lock
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c1e08e10] (complete)&work.complete
 -> [c1e08e08] &x->wait#6
 -> [c1e0a8bc] &rq->lock
 -> [c25db814] &x->wait#3
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1cde990] req_lock
 -> [c1e098e4] &p->pi_lock
 -> [c25db718] (complete)&req.done
 -> [c25db710] &x->wait#5
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c1e06400] subsys mutex#18
 -> [c1e0640c] subsys mutex#19
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1e0a16c] &wq->mutex
 -> [c1c82a10] kthread_create_lock
 -> [c1e0a360] (complete)&done
 -> [c1e0a358] &x->wait
 -> [c1c827b8] wq_pool_mutex
 -> [c259f24c] &(&base->lock)->rlock
 -> [c25c4058] &(&n->list_lock)->rlock
 -> [c2607b50] &(&k->k_lock)->rlock

c1c90058 FD:   42 BD:    8 +.+...: jump_label_mutex

c25bc904 FD:    1 BD:  164 ..-...: &(&zone->lock)->rlock

c1c934b8 FD:    2 BD:   77 +.+.+.: pcpu_alloc_mutex
 -> [c1c934f0] pcpu_lock

c1c934f0 FD:    1 BD:   80 ..-...: pcpu_lock

c25c4058 FD:    1 BD:    8 -.-...: &(&n->list_lock)->rlock

c1c7fec0 FD:   41 BD:    3 ++++++: cpu_hotplug.lock
 -> [c1c7fea8] cpu_hotplug.lock#2

c1c7fea8 FD:   40 BD:   26 +.+.+.: cpu_hotplug.lock#2
 -> [c1c7fe54] cpu_hotplug.wq.lock
 -> [c1e098e4] &p->pi_lock
 -> [c1c830d8] smpboot_threads_lock
 -> [c25bc6b4] &swhash->hlist_mutex
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c82a10] kthread_create_lock
 -> [c1e0a360] (complete)&done
 -> [c1e0a358] &x->wait
 -> [c1e0a8bc] &rq->lock
 -> [c1e0a184] &pool->attach_mutex
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c259f1d0] rcu_node_0
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1c8cf98] relay_channels_mutex
 -> [c1c7c378] smp_alt
 -> [c1c878d8] sparse_irq_lock
 -> [c1e09d9d] (complete)&st->done
 -> [c1e09d95] &x->wait#2

c1c93558 FD:   47 BD:   14 +.+.+.: slab_mutex
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)

c1e0aa3c FD:    1 BD:    2 +.+...: &dl_b->dl_runtime_lock

c1e0a8bc FD:    4 BD:  361 -.-.-.: &rq->lock
 -> [c1e0a9e8] &rt_b->rt_runtime_lock
 -> [c1e0aa54] &cp->lock

c1c6d034 FD:    5 BD:    1 ......: init_task.pi_lock
 -> [c1e0a8bc] &rq->lock

c259f13f FD:    1 BD:    1 ......: rcu_read_lock

c259f1d0 FD:    1 BD:   82 ..-...: rcu_node_0

c1c8d458 FD:   24 BD:    1 +.+.+.: trace_types_lock
 -> [c1c99ff0] pin_fs_lock
 -> [c1cc3234] &sb->s_type->i_mutex_key#6

c1c7f970 FD:    1 BD:    1 ......: panic_notifier_list.lock

c1c82a50 FD:    1 BD:    1 ......: die_chain.lock

c1c8d6d8 FD:   25 BD:    2 +.+.+.: trace_event_sem
 -> [c1c99ff0] pin_fs_lock
 -> [c1cc3234] &sb->s_type->i_mutex_key#6
 -> [c25c4058] &(&n->list_lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock

c1c8e238 FD:    1 BD:    1 ......: trigger_cmd_mutex

c1c7bdb0 FD:    1 BD:   72 -.-...: i8259A_lock

c259f0c4 FD:    4 BD:   70 -.-...: &irq_desc_lock_class
 -> [c1c7bdb0] i8259A_lock
 -> [c1c7e5b0] vector_lock
 -> [c1c7e6d0] ioapic_lock

c1c87bf8 FD:   10 BD:    3 +.+.+.: irq_domain_mutex
 -> [c1e0a8bc] &rq->lock
 -> [c1c7e5b0] vector_lock
 -> [c259f0c4] &irq_desc_lock_class
 -> [c1c7bdb0] i8259A_lock
 -> [c1c87b98] revmap_trees_mutex

c1c7c830 FD:    1 BD:   29 ......: rtc_lock

c1c898b0 FD:    2 BD:   64 -.-...: timekeeper_lock
 -> [c259ffc4] tk_core

c259ffc4 FD:    1 BD:   65 ----..: tk_core

c1c87830 FD:    1 BD:    1 ......: read_lock

c1c8fd98 FD:   55 BD:    1 +.+.+.: pmus_lock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c25db814] &x->wait#3
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1c8f9ec] subsys mutex#23
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1e0a8bc] &rq->lock

c25bc6b4 FD:    1 BD:   27 +.+...: &swhash->hlist_mutex

c1cd0eb0 FD:    1 BD:    4 ......: tty_ldiscs_lock

c1c87750 FD:    6 BD:   11 ......: (console_sem).lock
 -> [c1e098e4] &p->pi_lock

c1c8772c FD:   67 BD:   11 +.+.+.: console_lock
 -> [c1c80634] resource_lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c259f24c] &(&base->lock)->rlock
 -> [c1cd1750] kbd_event_lock
 -> [c1cccd30] vga_lock
 -> [c1c87710] logbuf_lock
 -> [c25d74d4] &port_lock_key
 -> [c25db814] &x->wait#3
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c25d5768] subsys mutex#12
 -> [c1b956b4] drivers/tty/vt/vt.c:231
 -> [c1cd1250] vt_event_lock
 -> [c1e0a8bc] &rq->lock
 -> [c1b95555] drivers/tty/vt/keyboard.c:252

c259f24c FD:    1 BD:  170 -.-.-.: &(&base->lock)->rlock

c1cd1750 FD:   10 BD:   23 -.-...: kbd_event_lock
 -> [c1cd1710] led_lock
 -> [c1e0a1a5] &pool->lock/1

c1cd1710 FD:    1 BD:   24 ..-...: led_lock

c1cccd30 FD:    1 BD:   12 ......: vga_lock

c1c87710 FD:    1 BD:   13 ......: logbuf_lock

c25d74d4 FD:    7 BD:   17 -.-...: &port_lock_key
 -> [c25d60c4] &tty->write_wait

c1c972d0 FD:    1 BD:   14 +.+...: vmap_area_lock

c1c97344 FD:    1 BD:    7 +.+...: init_mm.page_table_lock

c1c8a350 FD:    2 BD:    1 ......: clockevents_lock
 -> [c1c8a3d0] tick_broadcast_lock

c1c8a3d0 FD:    1 BD:    2 -.....: tick_broadcast_lock

c1c632e8 FD:    2 BD:   64 -.-...: jiffies_lock
 -> [c1c632c4] jiffies_lock#2

c1c632c4 FD:    1 BD:   65 ---...: jiffies_lock#2

c7eaf850 FD:    1 BD:   78 -.-...: hrtimer_bases.lock

c1c828f8 FD:    1 BD:    9 +.+...: text_mutex

c25d57d4 FD:    1 BD:    8 ......: semaphore->lock

c25d5ee4 FD:    1 BD:    5 ......: &(*(&acpi_gbl_reference_count_lock))->rlock

c1ccd33c FD:    3 BD:    2 +.+.+.: acpi_ioremap_lock
 -> [c1c972d0] vmap_area_lock
 -> [c1c97344] init_mm.page_table_lock

c1ccb9d0 FD:    1 BD:   13 ......: percpu_counters_lock

c25d2d9c FD:    1 BD:   81 ......: &(&idp->lock)->rlock

c1ccb5f0 FD:    6 BD:   80 ......: simple_ida_lock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1cc9300] (blk_queue_ida).idr.lock
 -> [c1ce3420] (host_index_ida).idr.lock
 -> [c1cf0de0] (input_ida).idr.lock
 -> [c1cf1980] (rtc_ida).idr.lock

c1c9de78 FD:   31 BD:   69 +.+.+.: kernfs_mutex
 -> [c1ccb5f0] simple_ida_lock
 -> [c1e0a8bc] &rq->lock
 -> [c1c63550] inode_hash_lock
 -> [c1c9e04c] &sb->s_type->i_lock_key#17
 -> [c25cf500] &isec->lock
 -> [c25bc904] &(&zone->lock)->rlock

c1c99db4 FD:    1 BD:    1 ++++..: file_systems_lock

c1c99f80 FD:    1 BD:   53 ......: (mnt_id_ida).idr.lock

c1c99ef0 FD:    2 BD:   52 +.+...: mnt_id_lock
 -> [c1c99f80] (mnt_id_ida).idr.lock

c1c99970 FD:    3 BD:   34 +.+...: sb_lock
 -> [c1c99940] (unnamed_dev_ida).idr.lock
 -> [c1c998f0] unnamed_dev_lock

c1c6caa5 FD:   29 BD:    1 +.+...: &type->s_umount_key/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c6cacc] &sb->s_type->i_lock_key
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1c99940 FD:    1 BD:   36 ......: (unnamed_dev_ida).idr.lock

c1c998f0 FD:    2 BD:   35 +.+...: unnamed_dev_lock
 -> [c1c99940] (unnamed_dev_ida).idr.lock

c1c90a18 FD:    1 BD:   27 +.+...: shrinker_rwsem

c1c6cacc FD:   17 BD:    8 +.+...: &sb->s_type->i_lock_key
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c25c41a4 FD:    1 BD:  120 +.+...: &(&s->s_inode_list_lock)->rlock

c25cf500 FD:    2 BD:  119 +.+...: &isec->lock
 -> [c25cf4f0] &(&sbsec->isec_lock)->rlock

c25cf4f0 FD:    1 BD:  120 +.+...: &(&sbsec->isec_lock)->rlock

c25c4628 FD:   16 BD:  172 +.+...: &(&dentry->d_lockref.lock)->rlock
 -> [c25c4600] &wq
 -> [c25c45f8] &wq#2
 -> [c25bcc48] &(&lru->node[i].lock)->rlock
 -> [c25c4629] &(&dentry->d_lockref.lock)->rlock/1
 -> [c25c6f7c] &wq#3
 -> [c1c9dc50] sysctl_lock
 -> [c25c462a] &(&dentry->d_lockref.lock)->rlock/2

c25cf4f8 FD:    1 BD:   28 +.+...: &sbsec->lock

c1cc7894 FD:    1 BD:    1 .+.+..: policy_rwlock

c1cc46d0 FD:    1 BD:   12 ......: notif_lock

c25ca4c0 FD:    1 BD:   12 ......: &(&avc_cache.slots_lock[i])->rlock

c1c635a8 FD:   19 BD:   53 +.+...: mount_lock
 -> [c1c63584] mount_lock#2

c1c63584 FD:   18 BD:   54 +.+...: mount_lock#2
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25c575c] &new_ns->poll

c1c9dbe0 FD:    1 BD:   26 ......: (proc_inum_ida).idr.lock

c1c9db90 FD:    2 BD:   25 ......: proc_inum_lock
 -> [c1c9dbe0] (proc_inum_ida).idr.lock

c1c9c0d4 FD:   18 BD:   73 +.+...: init_fs.lock
 -> [c1c9c0ec] init_fs.seq
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1c9c0ec FD:    1 BD:   74 +.+...: init_fs.seq

c1c9c2e5 FD:   27 BD:    1 +.+...: &type->s_umount_key#2/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c9c30c] &sb->s_type->i_lock_key#2
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1c9c30c FD:   17 BD:  103 +.+...: &sb->s_type->i_lock_key#2
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1c9dc14 FD:    1 BD:   13 ++++..: proc_subdir_lock

c1cff098 FD:  215 BD:    1 +.+.+.: net_mutex
 -> [c1c9dbe0] (proc_inum_ida).idr.lock
 -> [c1c9db90] proc_inum_lock
 -> [c1cff938] rtnl_mutex
 -> [c1c9dc50] sysctl_lock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1cfdbac] &sb->s_type->i_lock_key#7
 -> [c25e1900] slock-AF_NETLINK
 -> [c25e1a60] sk_lock-AF_NETLINK
 -> [c1d01e14] nl_table_lock
 -> [c1d01e50] nl_table_wait.lock
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c25e29b0] &(&net->rules_mod_lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c7ff18] cpu_add_remove_lock
 -> [c259f24c] &(&base->lock)->rlock
 -> [c1ccb9d0] percpu_counters_lock
 -> [c1cd8790] random_write_wait.lock
 -> [c1cd85c8] nonblocking_pool.lock
 -> [c1d038d4] raw_v4_hashinfo.lock
 -> [c1cfdda0] (net_generic_ids).idr.lock
 -> [c1d0bbf0] cache_list_lock
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c25e3ad0] &xt[i].mutex
 -> [c1d020d8] nf_hook_mutex
 -> [c1d07ab4] raw_v6_hashinfo.lock
 -> [c25efc40] &(&ip6addrlbl_table.lock)->rlock
 -> [c1c90058] jump_label_mutex

c1c9dc50 FD:    1 BD:  174 +.+...: sysctl_lock

c1c9c185 FD:   26 BD:    1 +.+...: &type->s_umount_key#3/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c1c9c1ac] &sb->s_type->i_lock_key#3
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1c9c1ac FD:   17 BD:    2 +.+...: &sb->s_type->i_lock_key#3
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1c8b7b0 FD:    1 BD:    2 +.....: cgroup_idr_lock

c1c8b770 FD:    1 BD:    2 ......: cgroup_file_kn_lock

c1c8b7f0 FD:    1 BD:    2 ......: css_set_lock

c1c8c678 FD:    2 BD:    1 +.+...: cpuset_mutex
 -> [c1c8c610] callback_lock

c1c8c610 FD:    1 BD:    2 ......: callback_lock

c1c8bbb8 FD:    1 BD:    2 +.+...: freezer_mutex

c1c63490 FD:    1 BD:    1 +.+...: kmap_lock

c1c971f0 FD:    2 BD:    1 +.+...: purge_lock
 -> [c1c972d0] vmap_area_lock

c1c7f570 FD:    2 BD:    1 +.+...: cpa_lock
 -> [c1c7f3f0] pgd_lock

c1c90630 FD:    1 BD:    1 +.+...: managed_page_count_lock

c25b38d4 FD:  130 BD:    4 .+.+.+: &cgroup_threadgroup_rwsem
 -> [c1c972d0] vmap_area_lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c1e098e4] &p->pi_lock
 -> [c1c99cd0] init_files.file_lock
 -> [c1c9c0d4] init_fs.lock
 -> [c1c6d010] init_task.alloc_lock
 -> [c1c99f80] (mnt_id_ida).idr.lock
 -> [c1c99ef0] mnt_id_lock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1c99970] sb_lock
 -> [c1c9db25] &type->s_umount_key#4/1
 -> [c1c635a8] mount_lock
 -> [c1c63250] pidmap_lock
 -> [c1c631d4] tasklist_lock
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c25c5748] &(&newf->file_lock)->rlock
 -> [c1c97344] init_mm.page_table_lock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)
 -> [c1c7f3f0] pgd_lock
 -> [c1dfe42c] &mm->context.lock
 -> [c1e09914] &mm->mmap_sem
 -> [c25c57bc] &(&fs->lock)->rlock

c1e098e4 FD:    5 BD:  337 -.-.-.: &p->pi_lock
 -> [c1e0a8bc] &rq->lock

c1c99cd0 FD:    1 BD:    5 +.+...: init_files.file_lock

c1c6d010 FD:    1 BD:    5 +.+...: init_task.alloc_lock

c1c9db25 FD:   55 BD:    5 +.+...: &type->s_umount_key#4/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c9db4c] &sb->s_type->i_lock_key#4
 -> [c25cf500] &isec->lock
 -> [c1c9db54] &sb->s_type->i_mutex_key
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1c9db4c FD:   17 BD:   10 +.+...: &sb->s_type->i_lock_key#4
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1c9db54 FD:   49 BD:    7 ++++.+: &sb->s_type->i_mutex_key
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1c9db4c] &sb->s_type->i_lock_key#4
 -> [c25cf500] &isec->lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c1c9dc50] sysctl_lock

c1c63250 FD:    1 BD:   79 ......: pidmap_lock

c1c631d4 FD:   23 BD:    5 .+.+..: tasklist_lock
 -> [c1c6edd4] init_sighand.siglock
 -> [c1e098a4] &(&sighand->siglock)->rlock

c1c6edd4 FD:    1 BD:    6 ......: init_sighand.siglock

c1da38a0 FD:    1 BD:    1 +.+...: (complete)kthreadd_done

c1da38b4 FD:    6 BD:    1 ......: (kthreadd_done).wait.lock
 -> [c1e098e4] &p->pi_lock

c1e098f4 FD:   40 BD:   72 +.+...: &(&p->alloc_lock)->rlock
 -> [c1e098ec] &p->mems_allowed_seq
 -> [c1c9c0d4] init_fs.lock
 -> [c25c57bc] &(&fs->lock)->rlock
 -> [c1e0a358] &x->wait
 -> [c1e098a4] &(&sighand->siglock)->rlock
 -> [c1e098ac] &x->wait#16

c1e098ec FD:    1 BD:   73 ......: &p->mems_allowed_seq

c1c7e698 FD:   11 BD:    2 +.+.+.: ioapic_mutex
 -> [c1e0a8bc] &rq->lock
 -> [c1c87bf8] irq_domain_mutex

c1e098a4 FD:   21 BD:   76 -.....: &(&sighand->siglock)->rlock
 -> [c1e098d4] &sig->wait_chldexit
 -> [c1cd86c8] input_pool.lock
 -> [c1cd85c8] nonblocking_pool.lock
 -> [c1e098c4] &(&(&sig->stats_lock)->lock)->rlock
 -> [c25d60a4] &(&tty->ctrl_lock)->rlock
 -> [c1e098e4] &p->pi_lock
 -> [c1e098dc] &prev->lock
 -> [c1e0989c] &sighand->signalfd_wqh
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c7eaf850] hrtimer_bases.lock
 -> [c7eeb850] hrtimer_bases.lock#4
 -> [c7ec3850] hrtimer_bases.lock#2
 -> [c7ed7850] hrtimer_bases.lock#3

c1c7e5b0 FD:    1 BD:   71 ......: vector_lock

c1c87b98 FD:    1 BD:    4 +.+.+.: revmap_trees_mutex

c1c7b770 FD:    1 BD:    1 ......: &nmi_desc[0].lock

c1c830d8 FD:   10 BD:   28 +.+.+.: smpboot_threads_lock
 -> [c1c82a10] kthread_create_lock
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a360] (complete)&done
 -> [c1e0a8bc] &rq->lock
 -> [c1e0a358] &x->wait
 -> [c1e0a348] (complete)&self.parked

c1c82a10 FD:    1 BD:   35 +.+...: kthread_create_lock

c1e0a360 FD:    7 BD:   34 +.+...: (complete)&done
 -> [c1e0a358] &x->wait
 -> [c1e0a8bc] &rq->lock

c1e0a358 FD:    6 BD:   99 ......: &x->wait
 -> [c1e098e4] &p->pi_lock

c1e0a348 FD:    7 BD:   29 +.+...: (complete)&self.parked
 -> [c1e0a358] &x->wait
 -> [c1e0a8bc] &rq->lock

c1c827b8 FD:   26 BD:   28 +.+.+.: wq_pool_mutex
 -> [c1e0a16c] &wq->mutex
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1e0a8bc] &rq->lock
 -> [c1c82a10] kthread_create_lock
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a360] (complete)&done
 -> [c1e0a358] &x->wait
 -> [c1e0a184] &pool->attach_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c25bc904] &(&zone->lock)->rlock

c1e0a184 FD:   12 BD:   31 +.+...: &pool->attach_mutex
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c25b3b90] &(&stopper->lock)->rlock
 -> [c25b3ba0] (complete)&done->completion
 -> [c1e0a8bc] &rq->lock
 -> [c25b3b98] &x->wait#7

c1e0a1a4 FD:    8 BD:  141 -.-...: &(&pool->lock)->rlock
 -> [c1e098e4] &p->pi_lock
 -> [c1c82750] wq_mayday_lock
 -> [c259f24c] &(&base->lock)->rlock

c1e0a16c FD:   11 BD:   29 +.+...: &wq->mutex
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c1e0a1a5] &pool->lock/1
 -> [c1e0a1cc] &x->wait#13

c1e0a1a5 FD:    8 BD:   81 -.-...: &pool->lock/1
 -> [c1e098e4] &p->pi_lock
 -> [c1c82750] wq_mayday_lock
 -> [c259f24c] &(&base->lock)->rlock

c259f190 FD:    6 BD:   62 ..-...: &rsp->gp_wq
 -> [c1e098e4] &p->pi_lock

c25b3b90 FD:    6 BD:   37 ..-...: &(&stopper->lock)->rlock
 -> [c1e098e4] &p->pi_lock

c1cd8648 FD:    1 BD:    1 ......: blocking_pool.lock

c25c5748 FD:   17 BD:    7 +.+...: &(&newf->file_lock)->rlock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1c82750 FD:    6 BD:  151 ..-...: wq_mayday_lock
 -> [c1e098e4] &p->pi_lock

c1c7fe54 FD:    1 BD:   27 ......: cpu_hotplug.wq.lock

c1c8cf98 FD:    1 BD:   27 +.+...: relay_channels_mutex

c1c7c378 FD:    1 BD:   27 +.+...: smp_alt

c1c878d8 FD:    6 BD:   27 +.+...: sparse_irq_lock
 -> [c1c7c830] rtc_lock
 -> [c1e0a8bc] &rq->lock

c1e09d9d FD:   30 BD:   27 +.+...: (complete)&st->done
 -> [c1e09d95] &x->wait#2
 -> [c1e0a8bc] &rq->lock
 -> [c1c827b8] wq_pool_mutex
 -> [c1e0a184] &pool->attach_mutex
 -> [c1c830d8] smpboot_threads_lock

c7ec3850 FD:    1 BD:   77 -.-...: hrtimer_bases.lock#2

c1e09d95 FD:    6 BD:   28 ......: &x->wait#2
 -> [c1e098e4] &p->pi_lock

c1e0a9e8 FD:    2 BD:  362 ......: &rt_b->rt_runtime_lock
 -> [c1e0a9d8] &rt_rq->rt_runtime_lock

c1e0a9d8 FD:    1 BD:  363 ......: &rt_rq->rt_runtime_lock

c7ed7850 FD:    1 BD:   79 -.-...: hrtimer_bases.lock#3

c7eeb850 FD:    1 BD:   77 -.-...: hrtimer_bases.lock#4

c1c85298 FD:   10 BD:    1 +.+.+.: sched_domains_mutex
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1e0aa3c] &dl_b->dl_runtime_lock
 -> [c1e0a8bc] &rq->lock
 -> [c1c934f0] pcpu_lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c9dc50] sysctl_lock

c1e0aa54 FD:    1 BD:  362 ......: &cp->lock

c1c92e65 FD:   31 BD:    1 +.+.+.: &type->s_umount_key#5/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1ccb9d0] percpu_counters_lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c92e8c] &sb->s_type->i_lock_key#5
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock
 -> [c25bca94] &(&sbinfo->stat_lock)->rlock

c259f254 FD:    6 BD:   17 +.-.-.: ((&timer))
 -> [c1e098e4] &p->pi_lock

c259f127 FD:    1 BD:    1 ......: rcu_callback

c1c92e8c FD:   17 BD:   12 +.+...: &sb->s_type->i_lock_key#5
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1cde880 FD:   70 BD:    1 +.+...: (complete)setup_done
 -> [c1cde894] (setup_done).wait.lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25c57bc] &(&fs->lock)->rlock
 -> [c1cde94c] &sb->s_type->i_lock_key#6
 -> [c1c6cacc] &sb->s_type->i_lock_key
 -> [c1c6cad4] &sb->s_type->i_mutex_key#2
 -> [c1c635a8] mount_lock
 -> [c1cde925] &type->s_umount_key#6/1
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c99970] sb_lock
 -> [c1c99ef0] mnt_id_lock
 -> [c1c99f80] (mnt_id_ida).idr.lock
 -> [c25ca4c0] &(&avc_cache.slots_lock[i])->rlock
 -> [c1cc46d0] notif_lock
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c1c99eb8] namespace_sem
 -> [c1c9db90] proc_inum_lock
 -> [c1c9dbe0] (proc_inum_ida).idr.lock

c1cde894 FD:    6 BD:    2 ......: (setup_done).wait.lock
 -> [c1e098e4] &p->pi_lock

c1c99eb8 FD:   27 BD:   47 +++++.: namespace_sem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c99f80] (mnt_id_ida).idr.lock
 -> [c1c99ef0] mnt_id_lock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1c635a8] mount_lock
 -> [c1c63528] rename_lock

c25c57b4 FD:    1 BD:   74 +.+...: &fs->seq

c1cde925 FD:   31 BD:    2 +.+.+.: &type->s_umount_key#6/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1ccb9d0] percpu_counters_lock
 -> [c25bca94] &(&sbinfo->stat_lock)->rlock
 -> [c1cde94c] &sb->s_type->i_lock_key#6
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c25bca94 FD:    1 BD:   46 +.+...: &(&sbinfo->stat_lock)->rlock

c1cde94c FD:   17 BD:   46 +.+...: &sb->s_type->i_lock_key#6
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1c6cad4 FD:   29 BD:    5 ++++++: &sb->s_type->i_mutex_key#2
 -> [c1c99eb8] namespace_sem
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c1c6cacc] &sb->s_type->i_lock_key

c1c63528 FD:   18 BD:   53 +.+...: rename_lock
 -> [c1c63504] rename_lock#2

c1c63504 FD:   17 BD:   54 +.+...: rename_lock#2
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25c462a] &(&dentry->d_lockref.lock)->rlock/2
 -> [c25c462b] &(&dentry->d_lockref.lock)->rlock/3

c25c575c FD:    1 BD:   55 ......: &new_ns->poll

c25c4620 FD:    2 BD:  175 +.+...: &dentry->d_seq
 -> [c25c4621] &dentry->d_seq/1

c25c57bc FD:   18 BD:   73 +.+...: &(&fs->lock)->rlock
 -> [c25c57b4] &fs->seq
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1cde990 FD:    1 BD:   34 +.+...: req_lock

c25db814 FD:    1 BD:   43 ......: &x->wait#3

c25d2da8 FD:    1 BD:   54 +.+...: &(&k->list_lock)->rlock

c25db698 FD:    3 BD:   47 ......: &(&dev->power.lock)->rlock
 -> [c25db699] &(&dev->power.lock)->rlock/1
 -> [c25db754] &dev->power.wait_queue

c1cdee58 FD:    1 BD:   45 +.+...: dpm_list_mtx

c1ccb6d8 FD:   12 BD:   64 +.+.+.: uevent_sock_mutex
 -> [c25e1d68] &(&net->nsid_lock)->rlock
 -> [c25e16dc] &(&list->lock)->rlock
 -> [c1d01e50] nl_table_wait.lock
 -> [c1e0a8bc] &rq->lock
 -> [c25bc904] &(&zone->lock)->rlock

c1c820b0 FD:    1 BD:   59 ......: running_helpers_waitq.lock

c1c87c58 FD:    4 BD:   12 +.+.+.: register_lock
 -> [c1c9dbe0] (proc_inum_ida).idr.lock
 -> [c1c9db90] proc_inum_lock
 -> [c25bc904] &(&zone->lock)->rlock

c1c82218 FD:    2 BD:    1 +.+...: umhelper_sem
 -> [c1c82070] usermodehelper_disabled_waitq.lock

c1c82070 FD:    1 BD:    2 ......: usermodehelper_disabled_waitq.lock

c1cff938 FD:  107 BD:    7 +.+.+.: rtnl_mutex
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c25db814] &x->wait#3
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c25e2924] subsys mutex#11
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1cdedf8] dev_hotplug_mutex
 -> [c1cff694] dev_base_lock
 -> [c1cd86c8] input_pool.lock
 -> [c1cd85c8] nonblocking_pool.lock
 -> [c1d01e50] nl_table_wait.lock
 -> [c2607354] &(&reg_requests_lock)->rlock
 -> [c259f24c] &(&base->lock)->rlock
 -> [c260734c] &(&reg_pending_beacons_lock)->rlock
 -> [c25e24e4] &tbl->lock
 -> [c1c9dc50] sysctl_lock
 -> [c2607344] &(&reg_indoor_lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c1d020d8] nf_hook_mutex
 -> [c1c90058] jump_label_mutex
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c1cff9b0] lweventlist_lock
 -> [c1c9dbe0] (proc_inum_ida).idr.lock
 -> [c1c9db90] proc_inum_lock
 -> [c25efb40] &ndev->lock
 -> [c25efcf2] &(&idev->mc_lock)->rlock
 -> [c25efd02] &(&mc->mca_lock)->rlock
 -> [c1d047d8] (inetaddr_chain).rwsem
 -> [c25e2148] _xmit_LOOPBACK
 -> [c25ee798] &(&in_dev->mc_tomb_lock)->rlock
 -> [c1d04a90] fib_info_lock
 -> [c25efb58] &(&ifa->lock)->rlock

c1cf5718 FD:    1 BD:    1 +.+...: cpufreq_fast_switch_lock

c1cddf58 FD:    1 BD:    1 +.+...: syscore_ops_lock

c1e0a18c FD:   26 BD:    1 +.+.+.: &pool->manager_arb
 -> [c259f24c] &(&base->lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c82a10] kthread_create_lock
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a360] (complete)&done
 -> [c1e0a8bc] &rq->lock
 -> [c1e0a358] &x->wait
 -> [c1e0a184] &pool->attach_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1e0a194] ((&pool->mayday_timer))
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)

c1c90578 FD:    2 BD:    1 +.+...: zonelists_mutex
 -> [c25bc904] &(&zone->lock)->rlock

c1c99a94 FD:    1 BD:    1 ++++..: binfmt_lock

c1e0a194 FD:   10 BD:    5 +.-...: ((&pool->mayday_timer))
 -> [c1e0a1a5] &pool->lock/1
 -> [c259f24c] &(&base->lock)->rlock
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1e0a144 FD:    1 BD:    1 .+.+.+: "events_unbound"

c1e0a0f8 FD:  133 BD:    3 +.+.+.: (&sub_info->work)
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25b38d4] &cgroup_threadgroup_rwsem
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a8bc] &rq->lock
 -> [c25c4058] &(&n->list_lock)->rlock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)
 -> [c1e098a4] &(&sighand->siglock)->rlock
 -> [c1e098d4] &sig->wait_chldexit
 -> [c1e098dc] &prev->lock
 -> [c1e0a0e8] &x->wait#12

c1cfdb85 FD:   27 BD:    1 +.+.+.: &type->s_umount_key#7/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1cfdbac] &sb->s_type->i_lock_key#7
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1cfdbac FD:   17 BD:    3 +.+...: &sb->s_type->i_lock_key#7
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1c82250 FD:    1 BD:    1 +.+...: umh_sysctl_lock

c1e098bc FD:  141 BD:    2 +.+.+.: &sig->cred_guard_mutex
 -> [c25c57bc] &(&fs->lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1c6cad4] &sb->s_type->i_mutex_key#2
 -> [c1e0a8bc] &rq->lock
 -> [c1c9c0d4] init_fs.lock
 -> [c1c9e3fc] &type->i_mutex_dir_key
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16
 -> [c1e098e4] &p->pi_lock
 -> [c25b3b90] &(&stopper->lock)->rlock
 -> [c25b3ba0] (complete)&done->completion
 -> [c25b3b98] &x->wait#7
 -> [c1c7f3f0] pgd_lock
 -> [c1e09914] &mm->mmap_sem
 -> [c25c874c] &ei->xattr_sem
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25c8744] &ei->i_data_sem
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c1e0990c] &(&mm->page_table_lock)->rlock
 -> [c25c3ce8] &anon_vma->rwsem
 -> [c1e0980c] &(ptlock_ptr(page))->rlock
 -> [c25bc8fc] &(&zone->lru_lock)->rlock
 -> [c25bc924] zone->wait_table + i
 -> [c1e098a4] &(&sighand->siglock)->rlock
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c25c5748] &(&newf->file_lock)->rlock
 -> [c25c873c] &ei->i_mmap_sem
 -> [c1dfe42c] &mm->context.lock
 -> [c25ba114] &(&tsk->delays->lock)->rlock
 -> [c25c567c] &mapping->i_mmap_rwsem
 -> [c25c3cdc] key#3
 -> [c1c9e3f4] &sb->s_type->i_mutex_key#8
 -> [c25b4244] &(kretprobe_table_locks[i].lock)

c1cfdcb8 FD:    1 BD:    1 +.+...: proto_list_mutex

c25c4600 FD:    6 BD:  173 ......: &wq
 -> [c1e098e4] &p->pi_lock

c1cd8790 FD:    1 BD:   16 ..-...: random_write_wait.lock

c25bc6c4 FD:    1 BD:    1 +.+...: &child->perf_event_mutex

c1d01e14 FD:    1 BD:    4 .+.+..: nl_table_lock

c1e098d4 FD:    6 BD:   77 ......: &sig->wait_chldexit
 -> [c1e098e4] &p->pi_lock

c1d01e50 FD:    1 BD:   69 ......: nl_table_wait.lock

c1cfdbf0 FD:    1 BD:    1 +.+...: net_family_lock

c1e098c4 FD:    3 BD:   77 ......: &(&(&sig->stats_lock)->lock)->rlock
 -> [c1e098cc] &(&sig->stats_lock)->seqcount

c1e098cc FD:    2 BD:   78 ......: &(&sig->stats_lock)->seqcount
 -> [c1c63250] pidmap_lock

c25e1900 FD:    1 BD:    3 +.....: slock-AF_NETLINK

c25e1a60 FD:   12 BD:    2 +.+...: sk_lock-AF_NETLINK
 -> [c25e1900] slock-AF_NETLINK

c1c80150 FD:    1 BD:    1 +.+...: low_water_lock

c25d2dfd FD:   10 BD:    5 +.....: &(&tbl->locks[i])->rlock
 -> [c25d2dfe] &(&tbl->locks[i])->rlock/1
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1c99ff0 FD:    1 BD:   11 +.+...: pin_fs_lock

c1cc3085 FD:   27 BD:    1 +.+.+.: &type->s_umount_key#8/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1cc30ac] &sb->s_type->i_lock_key#8
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1cc30ac FD:   17 BD:   10 +.+...: &sb->s_type->i_lock_key#8
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1cc30b4 FD:   22 BD:    8 +.+.+.: &sb->s_type->i_mutex_key#3
 -> [c1cc30ac] &sb->s_type->i_lock_key#8
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25bc904] &(&zone->lock)->rlock

c1cddc78 FD:   34 BD:   43 +.+.+.: gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccb630] kobj_ns_type_lock
 -> [c1e0a8bc] &rq->lock
 -> [c1e098e4] &p->pi_lock

c1c9dfd0 FD:    1 BD:   61 +.+...: sysfs_symlink_target_lock

c25d70dc FD:    8 BD:    1 +.+...: subsys mutex
 -> [c2607b50] &(&k->k_lock)->rlock

c2607b50 FD:    7 BD:   78 +.+...: &(&k->k_lock)->rlock
 -> [c1d19ed0] klist_remove_lock

c1cdf9d8 FD:    1 BD:    1 +.+...: regmap_debugfs_early_lock

c1cf1c38 FD:    1 BD:    1 +.+...: __i2c_board_lock

c1cf1eb8 FD:    8 BD:    1 +.+...: core_lock
 -> [c2607b50] &(&k->k_lock)->rlock

c1cf5c58 FD:   14 BD:    1 +.+...: cpuidle_lock
 -> [c1e0a8bc] &rq->lock
 -> [c259f118] (complete)&rs_array[i].completion
 -> [c259f110] &x->wait#4

c259f118 FD:   11 BD:    4 +.+...: (complete)&rs_array[i].completion
 -> [c1e0a8bc] &rq->lock
 -> [c259f24c] &(&base->lock)->rlock
 -> [c7ed7850] hrtimer_bases.lock#3
 -> [c1c898b0] timekeeper_lock
 -> [c1c632e8] jiffies_lock

c259f110 FD:    6 BD:    4 ..-...: &x->wait#4
 -> [c1e098e4] &p->pi_lock

c1ccd680 FD:    1 BD:   45 ++++..: bus_type_sem

c25df800 FD:    8 BD:    1 +.+...: subsys mutex#2
 -> [c2607b50] &(&k->k_lock)->rlock

c1c805f0 FD:    1 BD:   17 +.+...: bootmem_resource_lock

c1cfd730 FD:    1 BD:   15 ......: pci_config_lock

c1e0baa0 FD:    1 BD:    1 ......: &dev->mutex

c1cde52c FD:   52 BD:    2 +.+.+.: subsys mutex#3
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccff18] performance_mutex
 -> [c1cf5814] cpufreq_driver_lock
 -> [c25df56c] &policy->rwsem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c1cf5558] s_active#7
 -> [c1cf5654] s_active#8
 -> [c1cf561c] s_active#9
 -> [c1cf5638] s_active#10
 -> [c1cf5670] s_active#11
 -> [c1cf568c] s_active#12
 -> [c1cf5574] s_active#13
 -> [c1cf55ac] s_active#14
 -> [c1cf5590] s_active#15
 -> [c1cf55c8] s_active#16
 -> [c1cf553c] s_active#17
 -> [c25df544] &x->wait#14
 -> [c25df554] (complete)&policy->kobj_unregister

c1c81bf0 FD:    1 BD:    1 ......: uidhash_lock

c1e0a324 FD:    5 BD:    1 +.+...: s_active
 -> [c1e0a8bc] &rq->lock

c1cd1050 FD:    1 BD:    1 +.+...: sysrq_key_table_lock

c1c888b0 FD:    1 BD:    1 ....-.: freezer_lock

c1c90350 FD:    1 BD:    1 ......: oom_reaper_wait.lock

c1c8234c FD:    1 BD:    1 +.+...: subsys mutex#4

c25bc90c FD:    1 BD:    1 ......: &pgdat->kcompactd_wait

c1cc91d8 FD:   71 BD:    7 +.+.+.: bio_slab_lock

c1ccaf18 FD:    1 BD:   11 +.+.+.: block_class_lock

c1c99a58 FD:    1 BD:   23 +.+...: chrdevs_lock

c25d5eec FD:    1 BD:    1 ......: &(*(&acpi_gbl_hardware_lock))->rlock

c25d5ef4 FD:    1 BD:    2 ......: &(*(&acpi_gbl_gpe_lock))->rlock

c1c87358 FD:    1 BD:    1 +.+...: pm_mutex

c1ccd868 FD:   81 BD:    1 +.+.+.: acpi_scan_lock
 -> [c25d57d4] semaphore->lock
 -> [c25db814] &x->wait#3
 -> [c1ccd814] acpi_device_lock
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1ccd618] subsys mutex#5
 -> [c1e0a8bc] &rq->lock
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c25d5ee4] &(*(&acpi_gbl_reference_count_lock))->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1cfd730] pci_config_lock
 -> [c25d5b88] &(*(&acpi_gbl_global_lock_pending_lock))->rlock
 -> [c1ccd33c] acpi_ioremap_lock
 -> [c1ccdbe4] osc_lock
 -> [c1ccc1f8] pci_bus_sem
 -> [c1cfd658] pci_mmcfg_lock
 -> [c1c80634] resource_lock
 -> [c25d5adc] &device->physical_node_lock
 -> [c1cddc78] gdp_mutex
 -> [c25d2e48] subsys mutex#6
 -> [c1ccbdd0] pci_lock
 -> [c1ccc6f8] pci_slot_mutex
 -> [c1ccbf10] resource_alignment_lock
 -> [c1ccd5b8] acpi_pm_notifier_lock
 -> [c1ccc0ac] subsys mutex#7
 -> [c1ccbe38] pci_rescan_remove_lock
 -> [c1cddfec] subsys mutex#8
 -> [c1ccdcd8] acpi_link_lock
 -> [c1cde6cc] subsys mutex#9
 -> [c1cdefb0] events_lock
 -> [c25d5ef4] &(*(&acpi_gbl_gpe_lock))->rlock

c1ccd814 FD:    1 BD:    2 +.+.+.: acpi_device_lock

c1ccd618 FD:    1 BD:    2 +.+...: subsys mutex#5

c25d5b88 FD:    1 BD:    2 ......: &(*(&acpi_gbl_global_lock_pending_lock))->rlock

c1ccdbe4 FD:    3 BD:    2 +.+.+.: osc_lock
 -> [c25d57d4] semaphore->lock
 -> [c25d5ee4] &(*(&acpi_gbl_reference_count_lock))->rlock

c1ccc1f8 FD:    1 BD:    2 ++++..: pci_bus_sem

c1cfd658 FD:    1 BD:    2 +.+...: pci_mmcfg_lock

c25d5adc FD:   33 BD:    8 +.+.+.: &device->physical_node_lock
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex

c25d2e48 FD:    8 BD:    2 +.+...: subsys mutex#6
 -> [c2607b50] &(&k->k_lock)->rlock

c1ccbdd0 FD:    2 BD:   13 ......: pci_lock
 -> [c1cfd730] pci_config_lock

c1ccc6f8 FD:    1 BD:    2 +.+...: pci_slot_mutex

c1ccbf10 FD:    1 BD:    2 +.+...: resource_alignment_lock

c25db699 FD:    1 BD:   48 ......: &(&dev->power.lock)->rlock/1

c1ccd5b8 FD:    4 BD:    2 +.+.+.: acpi_pm_notifier_lock
 -> [c1cdefb0] events_lock
 -> [c25d57d4] semaphore->lock
 -> [c25d5ee4] &(*(&acpi_gbl_reference_count_lock))->rlock

c1cdefb0 FD:    1 BD:    3 ......: events_lock

c1ccc0ac FD:    1 BD:    2 +.+...: subsys mutex#7

c1ccbe38 FD:   11 BD:    2 +.+...: pci_rescan_remove_lock

c1cddfec FD:    1 BD:    2 +.+...: subsys mutex#8

c1ccdcd8 FD:    4 BD:    2 +.+.+.: acpi_link_lock
 -> [c25d57d4] semaphore->lock
 -> [c25d5ee4] &(*(&acpi_gbl_reference_count_lock))->rlock
 -> [c1cfd730] pci_config_lock

c1cde6cc FD:    1 BD:    2 +.+...: subsys mutex#9

c1cd9458 FD:  145 BD:    1 +.+.+.: misc_mtx
 -> [c25db814] &x->wait#3
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1cde990] req_lock
 -> [c1e098e4] &p->pi_lock
 -> [c25db718] (complete)&req.done
 -> [c25db710] &x->wait#5
 -> [c1e0a8bc] &rq->lock
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c25dae24] subsys mutex#10
 -> [c25bc904] &(&zone->lock)->rlock

c25db718 FD:  114 BD:   33 +.+...: (complete)&req.done
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1cde990] req_lock
 -> [c1e0a8bc] &rq->lock
 -> [c1cde94c] &sb->s_type->i_lock_key#6
 -> [c1cde954] &sb->s_type->i_mutex_key#5
 -> [c25b4244] &(kretprobe_table_locks[i].lock)

c25db710 FD:    6 BD:   33 ......: &x->wait#5
 -> [c1e098e4] &p->pi_lock

c1cde934 FD:  148 BD:    2 .+.+.+: sb_writers
 -> [c1cde955] &sb->s_type->i_mutex_key#4/1
 -> [c1cde954] &sb->s_type->i_mutex_key#5
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1cde94c] &sb->s_type->i_lock_key#6
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25c5780] &p->lock
 -> [c1e0a8bc] &rq->lock
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25bca94] &(&sbinfo->stat_lock)->rlock
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25cf4f0] &(&sbsec->isec_lock)->rlock
 -> [c1c999f0] cdev_lock
 -> [c25bc8fc] &(&zone->lru_lock)->rlock
 -> [c25bca84] &(&info->lock)->rlock
 -> [c25bcb38] &(&wb->list_lock)->rlock

c1cde955 FD:  121 BD:    3 +.+.+.: &sb->s_type->i_mutex_key#4/1
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25bca94] &(&sbinfo->stat_lock)->rlock
 -> [c1cde94c] &sb->s_type->i_lock_key#6
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c1cde954] &sb->s_type->i_mutex_key#5
 -> [c1e0a8bc] &rq->lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)
 -> [c1cde958] &sb->s_type->i_mutex_key#5/4
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25cf4f0] &(&sbsec->isec_lock)->rlock
 -> [c25efa68] &u->readlock

c1cde954 FD:  111 BD:   37 ++++++: &sb->s_type->i_mutex_key#5
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25bca94] &(&sbinfo->stat_lock)->rlock
 -> [c1cde94c] &sb->s_type->i_lock_key#6
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25bca7c] &(&xattrs->lock)->rlock
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25bca84] &(&info->lock)->rlock
 -> [c25c566c] &inode->i_size_seqcount
 -> [c25bc8c0] (PG_locked)page
 -> [c1e0a8bc] &rq->lock
 -> [c1cde958] &sb->s_type->i_mutex_key#5/4
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c99eb8] namespace_sem

c25dae24 FD:    8 BD:    2 +.+...: subsys mutex#10
 -> [c2607b50] &(&k->k_lock)->rlock

c1cddb70 FD:    3 BD:    1 ......: vga_lock#2
 -> [c1ccbdd0] pci_lock

c1cde578 FD:   55 BD:    3 +.+.+.: attribute_container_mutex
 -> [c25db814] &x->wait#3
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c25db6fc] subsys mutex#29
 -> [c1e0a8bc] &rq->lock

c1cdf0d8 FD:   32 BD:    1 +.+.+.: drivers_dir_mutex
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1e0a8bc] &rq->lock

c1cfa3b8 FD:    3 BD:    1 +.+.+.: info_mutex
 -> [c1c9dbe0] (proc_inum_ida).idr.lock
 -> [c1c9db90] proc_inum_lock

c1ccb630 FD:    1 BD:   44 +.+...: kobj_ns_type_lock

c25e2924 FD:    8 BD:    8 +.+...: subsys mutex#11
 -> [c2607b50] &(&k->k_lock)->rlock

c1cdedf8 FD:    4 BD:   15 +.+...: dev_hotplug_mutex
 -> [c25db698] &(&dev->power.lock)->rlock

c1cff694 FD:    1 BD:    8 +.....: dev_base_lock

c25dd080 FD:    1 BD:    1 ......: &syncp->seq

c1d01b94 FD:    1 BD:    1 +.+...: qdisc_mod_lock

c1d01fd8 FD:    8 BD:    1 +.+.+.: cb_lock
 -> [c1d02038] genl_mutex

c1d02038 FD:    7 BD:    2 +.+.+.: genl_mutex
 -> [c1e0a8bc] &rq->lock
 -> [c1d01e14] nl_table_lock
 -> [c1d01e50] nl_table_wait.lock

c1d02138 FD:    1 BD:    1 +.+...: afinfo_mutex

c1d01dd0 FD:    1 BD:    1 ......: netlink_chain.lock

c2607354 FD:    1 BD:    8 +.+...: &(&reg_requests_lock)->rlock

c1e0a15c FD:    1 BD:    1 .+.+.+: "events"

c1d0c400 FD:  108 BD:    1 +.+.+.: reg_work
 -> [c1cff938] rtnl_mutex

c260734c FD:    1 BD:    8 +.....: &(&reg_pending_beacons_lock)->rlock

c1d141b8 FD:    1 BD:    1 +.+.+.: rate_ctrl_mutex

c1d19970 FD:    1 BD:    1 +.+...: netlbl_domhsh_lock

c1d19a90 FD:    1 BD:    1 +.+...: netlbl_unlhsh_lock

c1cf0d98 FD:  155 BD:    5 +.+.+.: input_mutex
 -> [c1cf0d30] input_devices_poll_wait.lock
 -> [c25deac8] &dev->mutex#2
 -> [c1cf0de0] (input_ida).idr.lock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1e0a8bc] &rq->lock
 -> [c25db814] &x->wait#3
 -> [c1c99a58] chrdevs_lock
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1cde990] req_lock
 -> [c1e098e4] &p->pi_lock
 -> [c25db718] (complete)&req.done
 -> [c25db710] &x->wait#5
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c25deab0] subsys mutex#24
 -> [c25df718] subsys mutex#37
 -> [c1cf5f38] leds_list_lock
 -> [c1cf6018] triggers_list_lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25deb11] &mousedev->mutex/1

c1cf0d30 FD:    1 BD:    6 ......: input_devices_poll_wait.lock

c1e08e10 FD:   25 BD:    3 +.+...: (complete)&work.complete
 -> [c1e08e20] (&(&work.work)->work)
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c259f24c] &(&base->lock)->rlock
 -> [c1e0a194] ((&pool->mayday_timer))
 -> [c1e0a184] &pool->attach_mutex
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a358] &x->wait
 -> [c1e0a8bc] &rq->lock
 -> [c1c82a10] kthread_create_lock
 -> [c1ccb5f0] simple_ida_lock
 -> [c25d2d9c] &(&idp->lock)->rlock

c1e08e08 FD:    6 BD:    5 ......: &x->wait#6
 -> [c1e098e4] &p->pi_lock

c1e08e20 FD:    7 BD:    4 +.+...: (&(&work.work)->work)
 -> [c1e08e08] &x->wait#6

c1c8c858 FD:   10 BD:    3 +.+...: stop_cpus_mutex
 -> [c1c8c88c] stop_cpus_lock
 -> [c25b3ba0] (complete)&done->completion
 -> [c1e0a8bc] &rq->lock
 -> [c25b3b98] &x->wait#7

c1c8c88c FD:    7 BD:    4 +.+...: stop_cpus_lock
 -> [c25b3b90] &(&stopper->lock)->rlock

c25b3ba0 FD:    8 BD:   35 +.+...: (complete)&done->completion
 -> [c25b3b98] &x->wait#7
 -> [c25b3b90] &(&stopper->lock)->rlock
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a8bc] &rq->lock

c25b3b98 FD:    6 BD:   36 ......: &x->wait#7
 -> [c1e098e4] &p->pi_lock

c1cc3205 FD:   26 BD:    1 +.+.+.: &type->s_umount_key#9/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c1cc322c] &sb->s_type->i_lock_key#9
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1cc322c FD:   17 BD:    6 +.+...: &sb->s_type->i_lock_key#9
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1cc3234 FD:   22 BD:    4 +.+.+.: &sb->s_type->i_mutex_key#6
 -> [c1cc322c] &sb->s_type->i_lock_key#9
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25bc904] &(&zone->lock)->rlock

c1c8da78 FD:   26 BD:    1 +.+.+.: event_mutex
 -> [c1c99ff0] pin_fs_lock
 -> [c1cc3234] &sb->s_type->i_mutex_key#6
 -> [c1c8d6d8] trace_event_sem

c1c99b05 FD:   26 BD:    1 +.+.+.: &type->s_umount_key#10/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c1c99b2c] &sb->s_type->i_lock_key#10
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1c99b2c FD:   17 BD:    2 +.+...: &sb->s_type->i_lock_key#10
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1c635d0 FD:    1 BD:    7 +.+...: bdev_lock

c1c9c585 FD:   26 BD:    1 +.+.+.: &type->s_umount_key#11/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c1c9c5ac] &sb->s_type->i_lock_key#11
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1c9c5ac FD:   17 BD:    2 +.+...: &sb->s_type->i_lock_key#11
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1c9dd74 FD:    1 BD:    1 +.+...: kclist_lock

c1ca7585 FD:   27 BD:    1 +.+.+.: &type->s_umount_key#12/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1ca75ac] &sb->s_type->i_lock_key#12
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1ca75ac FD:   17 BD:    2 +.+...: &sb->s_type->i_lock_key#12
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c25d5768 FD:    8 BD:   12 +.+...: subsys mutex#12
 -> [c2607b50] &(&k->k_lock)->rlock

c1cd0318 FD:    1 BD:    1 +.+.+.: pnp_lock

c1cd03ec FD:    1 BD:    1 +.+...: subsys mutex#13

c25daa40 FD:    8 BD:    1 +.+...: subsys mutex#14
 -> [c2607b50] &(&k->k_lock)->rlock

c25d6084 FD:    8 BD:   12 +.+...: subsys mutex#15
 -> [c2607b50] &(&k->k_lock)->rlock

c25d63b0 FD:    8 BD:    1 +.+...: subsys mutex#16
 -> [c2607b50] &(&k->k_lock)->rlock

c1cd0d58 FD:  194 BD:    1 +.+.+.: tty_mutex
 -> [c1c87750] (console_sem).lock
 -> [c1c8772c] console_lock
 -> [c1c87710] logbuf_lock
 -> [c1cd0eb0] tty_ldiscs_lock
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c25d60ec] &tty->legacy_mutex
 -> [c25d6218] (&buf->work)
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c1e0a8bc] &rq->lock

c1cf6018 FD:   25 BD:    6 ++++.+: triggers_list_lock
 -> [c25df728] &led_cdev->trigger_lock

c1cf5f38 FD:    1 BD:    6 ++++..: leds_list_lock

c25df734 FD:    1 BD:    8 .+.?..: &trig->leddev_list_lock

c25ddce0 FD:    8 BD:    1 +.+...: subsys mutex#17
 -> [c2607b50] &(&k->k_lock)->rlock

c1cf3958 FD:    2 BD:    1 +.+...: thermal_governor_lock
 -> [c1cf39b8] thermal_list_lock

c1cf39b8 FD:    1 BD:    2 +.+...: thermal_list_lock

c1cf5778 FD:    1 BD:    1 +.+...: cpufreq_governor_mutex

c1cfd5d0 FD:    1 BD:    1 ......: pcibios_fwaddrmap_lock

c1cff6d0 FD:    1 BD:    1 +.+...: offload_lock

c1d049f0 FD:    1 BD:    1 +.....: inetsw_lock

c1cff710 FD:    1 BD:    1 +.+...: ptype_lock

c25e24e4 FD:    2 BD:    9 +.....: &tbl->lock
 -> [c259f24c] &(&base->lock)->rlock

c1e0a134 FD:    1 BD:    1 .+.+.+: "events_power_efficient"

c1d04720 FD:    2 BD:    1 +.+...: (check_lifetime_work).work
 -> [c259f24c] &(&base->lock)->rlock

c25e29b0 FD:    1 BD:    2 +.+...: &(&net->rules_mod_lock)->rlock

c1d06790 FD:    1 BD:    1 +.....: xfrm_state_afinfo_lock

c1d06650 FD:    1 BD:    1 +.+...: xfrm_policy_afinfo_lock

c1d067d0 FD:    1 BD:    1 +.....: xfrm_input_afinfo_lock

c1d038d4 FD:    1 BD:    2 +.....: raw_v4_hashinfo.lock

c1d035f0 FD:    1 BD:    1 +.+...: tcp_cong_list_lock

c1cfdda0 FD:    1 BD:    2 ......: (net_generic_ids).idr.lock

c1d0bbf0 FD:    1 BD:    3 +.+...: cache_list_lock

c26067c8 FD:    3 BD:    1 +.+...: (&(&cache_cleaner)->work)
 -> [c1d0bbf0] cache_list_lock
 -> [c259f24c] &(&base->lock)->rlock

c1d0bc58 FD:    1 BD:    1 +.+...: (rpc_pipefs_notifier_list).rwsem

c1d0bd30 FD:    1 BD:    1 +.+...: svc_xprt_class_lock

c1d092f0 FD:    1 BD:    1 +.+...: xprt_list_lock

c1c6cab4 FD:   34 BD:    1 .+.+.+: sb_writers#2
 -> [c1c6cad5] &sb->s_type->i_mutex_key#2/1
 -> [c1c6cad4] &sb->s_type->i_mutex_key#2

c1c6cad5 FD:   21 BD:    2 +.+.+.: &sb->s_type->i_mutex_key#2/1
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1c6cacc] &sb->s_type->i_lock_key
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock

c1c7c400 FD:   45 BD:    1 +.+...: (tsc_irqwork).work
 -> [c259f24c] &(&base->lock)->rlock
 -> [c1c89db8] clocksource_mutex

c26067c0 FD:    9 BD:    1 ..-...: (&(&cache_cleaner)->timer)
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1e06400 FD:    8 BD:    3 +.+...: subsys mutex#18
 -> [c2607b50] &(&k->k_lock)->rlock

c1e0640c FD:    8 BD:    3 +.+...: subsys mutex#19
 -> [c2607b50] &(&k->k_lock)->rlock

c1c0039a FD:    9 BD:    1 ..-...: net/wireless/reg.c:533
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1d0c380 FD:  108 BD:    1 +.+.+.: (crda_timeout).work
 -> [c1cff938] rtnl_mutex

c2607344 FD:    1 BD:    8 +.+...: &(&reg_indoor_lock)->rlock

c1c7ee00 FD:    2 BD:    1 +.+...: (bios_check_work).work
 -> [c259f24c] &(&base->lock)->rlock

c1cc79f8 FD:   11 BD:    1 +.+.+.: crypto_alg_sem
 -> [c25d1140] &x->wait#8
 -> [c1cc7998] (crypto_chain).rwsem

c1cc7998 FD:    9 BD:    2 .+.+.+: (crypto_chain).rwsem
 -> [c1c82a10] kthread_create_lock
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a360] (complete)&done
 -> [c1e0a358] &x->wait
 -> [c1e0a8bc] &rq->lock

c25d1148 FD:    1 BD:    1 +.+...: (complete)&larval->completion

c25d1140 FD:    6 BD:    2 ......: &x->wait#8
 -> [c1e098e4] &p->pi_lock

c1c89c8c FD:    1 BD:    1 +.+...: subsys mutex#20

c25debe4 FD:    9 BD:    1 +.+...: subsys mutex#21
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c1c89f30] rtcdev_lock

c1cddef8 FD:    1 BD:    6 +.+...: deferred_probe_mutex

c1cdde50 FD:    6 BD:    5 ......: probe_waitqueue.lock
 -> [c1e098e4] &p->pi_lock

c1c8a2cc FD:    1 BD:    1 +.+...: subsys mutex#22

c1c8ca10 FD:    1 BD:    1 ......: audit_freelist_lock

c1c87670 FD:    1 BD:    1 ......: printk_ratelimit_state.lock

c25b4244 FD:    1 BD:   57 ......: &(kretprobe_table_locks[i].lock)

c1c8f9ec FD:    1 BD:    2 +.+...: subsys mutex#23

c25bc91c FD:    1 BD:    1 ....-.: &pgdat->kswapd_wait

c1b4e159 FD:    9 BD:    1 ..-...: arch/x86/kernel/tsc.c:1128
 -> [c1e0a1a4] &(&pool->lock)->rlock

c25a0120 FD:   10 BD:    1 +.-...: (&watchdog_timer)
 -> [c1c89d10] watchdog_lock

c1b6ba22 FD:    9 BD:    1 ..-...: mm/vmstat.c:1493
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1c92f40 FD:   41 BD:    1 +.+...: (shepherd).work
 -> [c259f24c] &(&base->lock)->rlock
 -> [c1e0a8bc] &rq->lock

c1c89d40 FD:    9 BD:    1 +.+.+.: watchdog_work
 -> [c1c82a10] kthread_create_lock
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a360] (complete)&done
 -> [c1e0a358] &x->wait
 -> [c1e0a8bc] &rq->lock

c25bcaf8 FD:    1 BD:    1 .+.+..: "vmstat"

c25bcb08 FD:    2 BD:    1 +.+...: (&(({ do { const void *__vpp_verify = (typeof((&vmstat_work) + 0))((void *)0); (void)__vpp_verify; } while (0); ({ unsigned long __ptr; __asm__ ("" : "=r"(__ptr) : "0"((typeof(*((&vmstat_work))) *)((&vmstat_work)))); (typeof((typeof(*((&vmstat_work))) *)((&vmstat_work)))) (__ptr + (((__per_cpu_offset[(cpu)])))); }); }))->work)
 -> [c259f24c] &(&base->lock)->rlock

c1c9c645 FD:   26 BD:    1 +.+.+.: &type->s_umount_key#13/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c1c9c66c] &sb->s_type->i_lock_key#13
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1c9c66c FD:   17 BD:    2 +.+...: &sb->s_type->i_lock_key#13
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1c63690 FD:    1 BD:    1 +.+...: dq_list_lock

c1ca7910 FD:    1 BD:    1 +.+...: nfs_version_lock

c1cc3b30 FD:    1 BD:    2 +.+...: key_user_lock

c1cc3b70 FD:    1 BD:    2 +.+...: key_serial_lock

c1cc3a78 FD:    2 BD:    2 +.+...: key_construction_mutex
 -> [c1cc3c74] keyring_name_lock

c1cc3c74 FD:    1 BD:    3 ++++..: keyring_name_lock

c1cc3ad8 FD:    1 BD:    1 +.+...: key_types_sem

c1cc2eb0 FD:    1 BD:    1 +.+...: nls_lock

c1cc3705 FD:   27 BD:    1 +.+.+.: &type->s_umount_key#14/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1cc372c] &sb->s_type->i_lock_key#14
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1cc372c FD:   17 BD:    2 +.+...: &sb->s_type->i_lock_key#14
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1d020d8 FD:    1 BD:    8 +.+...: nf_hook_mutex

c1cc7305 FD:   27 BD:    1 +.+.+.: &type->s_umount_key#15/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c1cc732c] &sb->s_type->i_lock_key#15
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1cc732c FD:   17 BD:    2 +.+...: &sb->s_type->i_lock_key#15
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1cc9230 FD:    1 BD:    8 +.+...: elv_list_lock

c25d36fc FD:    1 BD:    1 +.+...: &(&drv->dynids.lock)->rlock

c25deab0 FD:    8 BD:    6 +.+...: subsys mutex#24
 -> [c2607b50] &(&k->k_lock)->rlock

c25deac8 FD:    1 BD:    6 +.+...: &dev->mutex#2

c1ccfa9c FD:   45 BD:    1 +.+.+.: register_count_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock

c1cf3a38 FD:    1 BD:    1 +.+.+.: thermal_idr_lock

c25dee90 FD:    8 BD:    1 +.+...: subsys mutex#25
 -> [c2607b50] &(&k->k_lock)->rlock

c1c83070 FD:    1 BD:    3 ......: async_lock

c25bcb00 FD:    9 BD:    1 ..-...: (&(({ do { const void *__vpp_verify = (typeof((&vmstat_work) + 0))((void *)0); (void)__vpp_verify; } while (0); ({ unsigned long __ptr; __asm__ ("" : "=r"(__ptr) : "0"((typeof(*((&vmstat_work))) *)((&vmstat_work)))); (typeof((typeof(*((&vmstat_work))) *)((&vmstat_work)))) (__ptr + (((__per_cpu_offset[(cpu)])))); }); }))->timer)
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1e0a3a4 FD:  231 BD:    1 +.+.+.: (&entry->work)
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1e0a8bc] &rq->lock
 -> [c1c9de78] kernfs_mutex
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c1c83070] async_lock
 -> [c1c83030] async_done.lock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c7ed7850] hrtimer_bases.lock#3
 -> [c25db814] &x->wait#3
 -> [c25dbbe0] &(shost->host_lock)->rlock
 -> [c1cde578] attribute_container_mutex
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c25dbbd0] &shost->scan_mutex
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25d2788] (complete)&wait
 -> [c25d2780] &x->wait#10
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25ba114] &(&tsk->delays->lock)->rlock
 -> [c1cddc78] gdp_mutex
 -> [c25b4244] &(kretprobe_table_locks[i].lock)
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c1e098e4] &p->pi_lock
 -> [c1cdee58] dpm_list_mtx
 -> [c25bcb50] subsys mutex#26
 -> [c1c99ff0] pin_fs_lock
 -> [c1cc30b4] &sb->s_type->i_mutex_key#3
 -> [c1c930d0] bdi_lock
 -> [c1ccaf18] block_class_lock
 -> [c1cde990] req_lock
 -> [c25db718] (complete)&req.done
 -> [c25db710] &x->wait#5
 -> [c25d280c] subsys mutex#27
 -> [c1cdedf8] dev_hotplug_mutex
 -> [c1c63550] inode_hash_lock
 -> [c1c635d0] bdev_lock
 -> [c1c9c30c] &sb->s_type->i_lock_key#2
 -> [c25d2824] &ev->block_mutex
 -> [c25c57e4] &bdev->bd_mutex
 -> [c25d282c] &(&ev->lock)->rlock
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c1ccac58] disk_events_mutex

c1c83030 FD:    6 BD:    2 ......: async_done.lock
 -> [c1e098e4] &p->pi_lock

c1cd4cd8 FD:  163 BD:    1 +.+.+.: serial_mutex
 -> [c1cd4ab8] port_mutex

c1cd4ab8 FD:  162 BD:    2 +.+.+.: port_mutex
 -> [c25d6238] &port->mutex

c25d6238 FD:  161 BD:   11 +.+.+.: &port->mutex
 -> [c1c805f0] bootmem_resource_lock
 -> [c1c80634] resource_lock
 -> [c25d74d4] &port_lock_key
 -> [c1c99a58] chrdevs_lock
 -> [c25db814] &x->wait#3
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1cde990] req_lock
 -> [c1e098e4] &p->pi_lock
 -> [c25db718] (complete)&req.done
 -> [c25db710] &x->wait#5
 -> [c1e0a8bc] &rq->lock
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c25d6084] subsys mutex#15
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25d6228] &(&port->lock)->rlock
 -> [c1cd4dd8] hash_mutex
 -> [c25d7500] &(&i->lock)->rlock
 -> [c259f0c4] &irq_desc_lock_class
 -> [c1c87c58] register_lock
 -> [c1c9dbe0] (proc_inum_ida).idr.lock
 -> [c1c9db90] proc_inum_lock
 -> [c25d6240] &port->delta_msr_wait
 -> [c25d7508] (&up->timer)
 -> [c259f24c] &(&base->lock)->rlock
 -> [c25d6248] &port->open_wait
 -> [c25d60c4] &tty->write_wait

c25db6a0 FD:    1 BD:    6 ......: &(&dev->devres_lock)->rlock

c1cddde8 FD:    1 BD:    1 +.+...: s_active#2

c1cdde04 FD:    1 BD:    1 +.+...: s_active#3

c1ccc19c FD:    1 BD:    1 +.+...: s_active#4

c1ccc180 FD:    1 BD:    1 +.+...: s_active#5

c1cddd94 FD:    1 BD:    1 +.+...: s_active#6

c1d19ed0 FD:    6 BD:   79 +.+...: klist_remove_lock
 -> [c1e098e4] &p->pi_lock

c25db6b4 FD:    1 BD:    3 .+.+..: &(&priv->bus_notifier)->rwsem

c25db660 FD:    1 BD:    1 +.....: &(&dev->queue_lock)->rlock

c1cdfdf8 FD:  180 BD:    4 +.+.+.: loop_index_mutex
 -> [c1e0a8bc] &rq->lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1cc9300] (blk_queue_ida).idr.lock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1cc91d8] bio_slab_lock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1e0a16c] &wq->mutex
 -> [c1c82a10] kthread_create_lock
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a360] (complete)&done
 -> [c1e0a358] &x->wait
 -> [c1c827b8] wq_pool_mutex
 -> [c1ccb9d0] percpu_counters_lock
 -> [c1ccabd0] blk_mq_cpu_notify_lock
 -> [c1cca998] all_q_mutex
 -> [c25db814] &x->wait#3
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c25bcb50] subsys mutex#26
 -> [c1c99ff0] pin_fs_lock
 -> [c1cc30b4] &sb->s_type->i_mutex_key#3
 -> [c1c930d0] bdi_lock
 -> [c1ccaf18] block_class_lock
 -> [c1cde990] req_lock
 -> [c25db718] (complete)&req.done
 -> [c25db710] &x->wait#5
 -> [c25d280c] subsys mutex#27
 -> [c1cdedf8] dev_hotplug_mutex
 -> [c25d2718] &(&q->__queue_lock)->rlock

c1cc9300 FD:    1 BD:   81 ......: (blk_queue_ida).idr.lock

c1ccabd0 FD:    1 BD:    5 +.+...: blk_mq_cpu_notify_lock

c1cca998 FD:   48 BD:    5 +.+.+.: all_q_mutex
 -> [c25d2794] &set->tag_list_lock
 -> [c25d2720] &q->sysfs_lock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c25bc904] &(&zone->lock)->rlock

c25d2794 FD:    1 BD:    6 +.+...: &set->tag_list_lock

c25d2720 FD:   21 BD:    7 +.+.+.: &q->sysfs_lock
 -> [c1cc9230] elv_list_lock
 -> [c25d2718] &(&q->__queue_lock)->rlock

c25bcb50 FD:    8 BD:    8 +.+...: subsys mutex#26
 -> [c2607b50] &(&k->k_lock)->rlock

c1c930d0 FD:    1 BD:    8 +.....: bdi_lock

c25d280c FD:    8 BD:    8 +.+...: subsys mutex#27
 -> [c2607b50] &(&k->k_lock)->rlock

c25d2718 FD:   19 BD:   80 -.-...: &(&q->__queue_lock)->rlock
 -> [c25dbc3c] &(&sdev->list_lock)->rlock
 -> [c259f24c] &(&base->lock)->rlock
 -> [c25d2780] &x->wait#10
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25d2774] &(&ioc->lock)->rlock
 -> [c25dbbe0] &(shost->host_lock)->rlock
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c25d26bc] &x->wait#15
 -> [c1cd85c8] nonblocking_pool.lock
 -> [c25bc924] zone->wait_table + i
 -> [c1cd86c8] input_pool.lock
 -> [c1cd87d0] random_read_wait.lock

c25dbd88 FD:  147 BD:    3 +.+.+.: subsys mutex#28
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c25db814] &x->wait#3
 -> [c1ce48d4] sg_index_lock
 -> [c1c99a58] chrdevs_lock
 -> [c1e0a8bc] &rq->lock
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1e098e4] &p->pi_lock
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1cde990] req_lock
 -> [c25db718] (complete)&req.done
 -> [c25db710] &x->wait#5
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c25dbf04] subsys mutex#34

c25dbfa8 FD:   23 BD:   74 -.-...: &(&host->lock)->rlock
 -> [c25dbbe0] &(shost->host_lock)->rlock
 -> [c25dbfc0] &ap->eh_wait_q
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c25dbfe8] &x->wait#9
 -> [c1ce6650] ata_scsi_rbuf_lock
 -> [c1e098e4] &p->pi_lock
 -> [c25d2718] &(&q->__queue_lock)->rlock

c1ce4970 FD:    1 BD:    1 +.+...: lock

c25db6fc FD:    8 BD:    4 +.+...: subsys mutex#29
 -> [c2607b50] &(&k->k_lock)->rlock

c1ce3420 FD:    1 BD:   81 ......: (host_index_ida).idr.lock

c1ce0578 FD:   71 BD:    1 +.+.+.: host_cmd_pool_mutex

c1ce3a8c FD:    1 BD:    3 +.+...: subsys mutex#30

c25dbbc0 FD:    8 BD:    1 +.+...: subsys mutex#31
 -> [c2607b50] &(&k->k_lock)->rlock

c25db754 FD:    1 BD:   48 ......: &dev->power.wait_queue

c25dbbe0 FD:    6 BD:   82 -.-...: &(shost->host_lock)->rlock
 -> [c1e098e4] &p->pi_lock

c25dbfc0 FD:    6 BD:   75 ......: &ap->eh_wait_q
 -> [c1e098e4] &p->pi_lock

c25dd034 FD:   24 BD:   10 +.+...: (&(&ap->sff_pio_task)->work)
 -> [c25dbfa8] &(&host->lock)->rlock

c25dbfa0 FD:   29 BD:    9 +.+...: &host->eh_mutex
 -> [c25dbfb0] (&ap->fastdrain_timer)
 -> [c259f24c] &(&base->lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c1ce7850] piix_lock
 -> [c1ccbdd0] pci_lock
 -> [c25dd034] (&(&ap->sff_pio_task)->work)
 -> [c1e0a1a4] &(&pool->lock)->rlock

c25dbfb0 FD:    1 BD:   10 ......: (&ap->fastdrain_timer)

c1ce7850 FD:    3 BD:   10 ......: piix_lock
 -> [c1ccbdd0] pci_lock

c1cff650 FD:    1 BD:    1 +.+...: napi_hash_lock

c1ce9ab8 FD:    5 BD:    1 +.+...: e1000_eeprom_lock
 -> [c1e0a8bc] &rq->lock

c25dd024 FD:    1 BD:    1 .+.+..: "ata_sff"

c25dbfe8 FD:    6 BD:   75 -.-...: &x->wait#9
 -> [c1e098e4] &p->pi_lock

c25dbbd8 FD:    6 BD:    5 ......: &shost->host_wait
 -> [c1e098e4] &p->pi_lock

c25dbbd0 FD:  208 BD:    2 +.+.+.: &shost->scan_mutex
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c25dbbe0] &(shost->host_lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1cc9300] (blk_queue_ida).idr.lock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1cc91d8] bio_slab_lock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1e0a16c] &wq->mutex
 -> [c1e0a8bc] &rq->lock
 -> [c1c82a10] kthread_create_lock
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a360] (complete)&done
 -> [c1e0a358] &x->wait
 -> [c1c827b8] wq_pool_mutex
 -> [c1ccb9d0] percpu_counters_lock
 -> [c25d2720] &q->sysfs_lock
 -> [c25db814] &x->wait#3
 -> [c1cde578] attribute_container_mutex
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c25d2788] (complete)&wait
 -> [c25d2780] &x->wait#10
 -> [c25dbc34] &sdev->inquiry_mutex
 -> [c259f118] (complete)&rs_array[i].completion
 -> [c259f110] &x->wait#4
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c1ce3a8c] subsys mutex#30
 -> [c1cddc78] gdp_mutex
 -> [c25dbd88] subsys mutex#28
 -> [c1ccb178] bsg_mutex
 -> [c25ba114] &(&tsk->delays->lock)->rlock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)

c25dbc3c FD:    1 BD:   81 ..-...: &(&sdev->list_lock)->rlock

c1ce6650 FD:    1 BD:   75 -.-...: ata_scsi_rbuf_lock

c25d2780 FD:    6 BD:   81 ..-...: &x->wait#10
 -> [c1e098e4] &p->pi_lock

c25d2788 FD:   37 BD:    8 +.+...: (complete)&wait
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c259f24c] &(&base->lock)->rlock
 -> [c259f1d0] rcu_node_0
 -> [c259f0c4] &irq_desc_lock_class
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c25dbbe0] &(shost->host_lock)->rlock
 -> [c25dbfa0] &host->eh_mutex
 -> [c25dbfe8] &x->wait#9
 -> [c259f254] ((&timer))
 -> [c1e0a8bc] &rq->lock
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c25dd034] (&(&ap->sff_pio_task)->work)
 -> [c1cd87d0] random_read_wait.lock
 -> [c1cd86c8] input_pool.lock
 -> [c7eaf850] hrtimer_bases.lock

c1ce9a50 FD:    1 BD:    1 ......: e1000_phy_lock

c25dbc34 FD:    1 BD:    3 +.+...: &sdev->inquiry_mutex

c1cff9b0 FD:    9 BD:    8 ......: lweventlist_lock
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1cff9e0 FD:  108 BD:    1 +.+...: (linkwatch_work).work
 -> [c1cff938] rtnl_mutex

c1ce45c0 FD:    1 BD:    4 ......: (sd_index_ida).idr.lock

c1ce45f0 FD:    2 BD:    3 +.+...: sd_index_lock
 -> [c1ce45c0] (sd_index_ida).idr.lock

c25dbebc FD:    8 BD:    3 +.+...: subsys mutex#32
 -> [c2607b50] &(&k->k_lock)->rlock

c25ba114 FD:    1 BD:   69 ......: &(&tsk->delays->lock)->rlock

c25de438 FD:    8 BD:    1 +.+...: subsys mutex#33
 -> [c2607b50] &(&k->k_lock)->rlock

c1cebbf8 FD:    1 BD:    1 +.+...: usb_bus_idr_lock

c1ce48d4 FD:    1 BD:    4 ......: sg_index_lock

c25dbf04 FD:    8 BD:    4 +.+...: subsys mutex#34
 -> [c2607b50] &(&k->k_lock)->rlock

c1ccb178 FD:  145 BD:    3 +.+.+.: bsg_mutex
 -> [c25db814] &x->wait#3
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c1ccb5f0] simple_ida_lock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1cde990] req_lock
 -> [c1e098e4] &p->pi_lock
 -> [c25db718] (complete)&req.done
 -> [c25db710] &x->wait#5
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c25d2cd8] subsys mutex#35

c1c63550 FD:   21 BD:   81 +.+...: inode_hash_lock
 -> [c1c9c30c] &sb->s_type->i_lock_key#2
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16
 -> [c1c9e04c] &sb->s_type->i_lock_key#17

c1cf0730 FD:    2 BD:    7 -.-...: i8042_lock
 -> [c25de860] &x->wait#11

c25d2824 FD:   80 BD:    5 +.+...: &ev->block_mutex
 -> [c25d282c] &(&ev->lock)->rlock
 -> [c25d281c] (&(&ev->dwork)->work)
 -> [c1e0a1a4] &(&pool->lock)->rlock

c25d282c FD:    9 BD:    8 ......: &(&ev->lock)->rlock
 -> [c1e0a1a4] &(&pool->lock)->rlock

c25c57e4 FD:  206 BD:    3 +.+.+.: &bdev->bd_mutex
 -> [c1ce4578] sd_ref_mutex
 -> [c1c9c314] &sb->s_type->i_mutex_key#7
 -> [c1c63550] inode_hash_lock
 -> [c1c99970] sb_lock
 -> [c1e0a8bc] &rq->lock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c25d2788] (complete)&wait
 -> [c25d2780] &x->wait#10
 -> [c1c972d0] vmap_area_lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25c5674] &(&mapping->private_lock)->rlock
 -> [c25bc924] zone->wait_table + i
 -> [c25d282c] &(&ev->lock)->rlock
 -> [c25bc8fc] &(&zone->lru_lock)->rlock
 -> [c1c9c30c] &sb->s_type->i_lock_key#2
 -> [c1cf4930] all_mddevs_lock
 -> [c25def74] &mddev->open_mutex
 -> [c1c635d0] bdev_lock
 -> [c1ce47f8] sr_mutex
 -> [c1cdfdf8] loop_index_mutex
 -> [c25dbab8] &lo->lo_ctl_mutex

c1ce4578 FD:    1 BD:    7 +.+...: sd_ref_mutex

c1c9c314 FD:    2 BD:    4 +.+...: &sb->s_type->i_mutex_key#7
 -> [c25c566c] &inode->i_size_seqcount

c25c566c FD:    1 BD:   63 +.+...: &inode->i_size_seqcount

c25d2cd8 FD:    8 BD:    4 +.+...: subsys mutex#35
 -> [c2607b50] &(&k->k_lock)->rlock

c25de860 FD:    1 BD:    8 -.....: &x->wait#11

c25c6f84 FD:    1 BD:   13 +.+...: &(&ent->pde_unload_lock)->rlock

c1cf05b0 FD:    9 BD:    3 ......: serio_event_lock
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1e0a14c FD:    1 BD:    1 .+.+.+: "events_long"

c1cf0560 FD:  174 BD:    1 +.+.+.: serio_event_work
 -> [c1cf0618] serio_mutex
 -> [c1e0a8bc] &rq->lock

c1cf0618 FD:  173 BD:    2 +.+.+.: serio_mutex
 -> [c1cf05b0] serio_event_lock
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c25db6b4] &(&priv->bus_notifier)->rwsem
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c1cf03ac] subsys mutex#36
 -> [c1e098e4] &p->pi_lock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)
 -> [c25bc904] &(&zone->lock)->rlock

c1cf0de0 FD:    1 BD:   81 ......: (input_ida).idr.lock

c25bc8c0 FD:   93 BD:   61 +.+...: (PG_locked)page
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25c5674] &(&mapping->private_lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c25bc8fc] &(&zone->lru_lock)->rlock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c259f24c] &(&base->lock)->rlock
 -> [c259f0c4] &irq_desc_lock_class
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c25bc924] zone->wait_table + i
 -> [c1e0980c] &(ptlock_ptr(page))->rlock
 -> [c7eeb850] hrtimer_bases.lock#4
 -> [c7eaf850] hrtimer_bases.lock
 -> [c1c898b0] timekeeper_lock
 -> [c1c632e8] jiffies_lock
 -> [c7ed7850] hrtimer_bases.lock#3
 -> [c7ec3850] hrtimer_bases.lock#2
 -> [c25c566c] &inode->i_size_seqcount
 -> [c25bca84] &(&info->lock)->rlock
 -> [c259f1d0] rcu_node_0
 -> [c259f190] &rsp->gp_wq
 -> [c25d2d68] (&cfqd->idle_slice_timer)
 -> [c1cd87d0] random_read_wait.lock
 -> [c25c88c0] &(&sbi->s_bal_lock)->rlock
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c25bcb38] &(&wb->list_lock)->rlock
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16
 -> [c25c8744] &ei->i_data_sem
 -> [c25c89a0] &(&journal->j_list_lock)->rlock
 -> [c25c879c] &(&ei->i_raw_lock)->rlock

c25c5684 FD:    5 BD:   69 ..-...: &(&mapping->tree_lock)->rlock
 -> [c259f24c] &(&base->lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25d2d74] &pl->lock

c25c5674 FD:    1 BD:   65 +.+...: &(&mapping->private_lock)->rlock

c259f12f FD:    1 BD:    1 ......: rcu_read_lock_sched

c25deb11 FD:    1 BD:    6 +.+...: &mousedev->mutex/1

c25bc924 FD:    6 BD:   90 ..-...: zone->wait_table + i
 -> [c1e098e4] &p->pi_lock

c25bc8fc FD:    1 BD:   71 ......: &(&zone->lru_lock)->rlock

c1cf03ac FD:    1 BD:    3 +.+...: subsys mutex#36

c1ccac58 FD:    1 BD:    3 +.+...: disk_events_mutex

c1e0a12c FD:    1 BD:    1 .+.+.+: "events_freezable_power_efficient"

c25d281c FD:   79 BD:    6 +.+.+.: (&(&ev->dwork)->work)
 -> [c1ce4578] sd_ref_mutex
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c25d2788] (complete)&wait
 -> [c25d2780] &x->wait#10
 -> [c1e0a8bc] &rq->lock
 -> [c25ba114] &(&tsk->delays->lock)->rlock
 -> [c25d282c] &(&ev->lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock

c25d2774 FD:    9 BD:   81 ......: &(&ioc->lock)->rlock
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1ce46d0 FD:    1 BD:    3 +.+...: sr_index_lock

c25de840 FD:  167 BD:    3 +.+.+.: &serio->drv_mutex
 -> [c25db814] &x->wait#3
 -> [c25de848] &serio->lock
 -> [c25deaa7] &ps2dev->cmd_mutex
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1e0a8bc] &rq->lock
 -> [c1c9de78] kernfs_mutex
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c25deab0] subsys mutex#24
 -> [c1cf0d98] input_mutex
 -> [c1cf0730] i8042_lock
 -> [c25db6a0] &(&dev->devres_lock)->rlock
 -> [c1cf12f8] psmouse_mutex

c25dbbb0 FD:    9 BD:    1 ..-...: (&(&cmd->abort_work)->timer)
 -> [c1e0a1a5] &pool->lock/1

c25de848 FD:   16 BD:    7 -.-...: &serio->lock
 -> [c25dea9f] &ps2dev->wait
 -> [c25deac0] &(&dev->event_lock)->rlock

c25deaa7 FD:   22 BD:    5 +.+...: &ps2dev->cmd_mutex
 -> [c1e0a8bc] &rq->lock
 -> [c1cf06f8] i8042_mutex

c25dbbc8 FD:    1 BD:    1 .+.+..: "scsi_tmf_%d"shost->host_no

c25dbbb8 FD:    7 BD:    1 +.+...: (&(&cmd->abort_work)->work)
 -> [c25dbbe0] &(shost->host_lock)->rlock

c1cf06f8 FD:   21 BD:    6 +.+...: i8042_mutex
 -> [c25de848] &serio->lock
 -> [c1cf0730] i8042_lock
 -> [c1e0a8bc] &rq->lock
 -> [c25dea9f] &ps2dev->wait
 -> [c259f24c] &(&base->lock)->rlock
 -> [c259f254] ((&timer))
 -> [c25b4244] &(kretprobe_table_locks[i].lock)

c25dea9f FD:    6 BD:    8 -.-...: &ps2dev->wait
 -> [c1e098e4] &p->pi_lock

c1ceb158 FD:    1 BD:    3 +.+...: cdrom_mutex

c1cf1980 FD:    1 BD:   81 ......: (rtc_ida).idr.lock

c25d2738 FD:    9 BD:    1 +.-...: ((&q->timeout))
 -> [c1e0a1a4] &(&pool->lock)->rlock

c25dec0c FD:    2 BD:    1 +.+...: &rtc->ops_lock
 -> [c1c7c830] rtc_lock

c25d2700 FD:    1 BD:    1 .+.+..: "kblockd"

c25d2708 FD:   20 BD:    1 +.+...: (&q->timeout_work)
 -> [c25d2718] &(&q->__queue_lock)->rlock

c1c89f30 FD:    1 BD:    2 ......: rtcdev_lock

c1cf4ef8 FD:    1 BD:    1 +.+...: _lock

c25df718 FD:    8 BD:    6 +.+...: subsys mutex#37
 -> [c2607b50] &(&k->k_lock)->rlock

c25df728 FD:   24 BD:    7 +.+.+.: &led_cdev->trigger_lock
 -> [c1e0a8bc] &rq->lock
 -> [c25df734] &trig->leddev_list_lock
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock

c25deac0 FD:   14 BD:   11 -.-...: &(&dev->event_lock)->rlock
 -> [c1cd86c8] input_pool.lock
 -> [c1cd87d0] random_read_wait.lock

c1cf53f0 FD:    1 BD:    1 +.+...: _lock#2

c1cf12f8 FD:  165 BD:    4 +.+.+.: psmouse_mutex
 -> [c1e0a8bc] &rq->lock
 -> [c25db814] &x->wait#3
 -> [c25de848] &serio->lock
 -> [c25deaa7] &ps2dev->cmd_mutex
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c2607b50] &(&k->k_lock)->rlock
 -> [c25deab0] subsys mutex#24
 -> [c1cf0d98] input_mutex

c1cfa318 FD:    1 BD:    1 +.+...: snd_ioctl_rwsem

c1cfa418 FD:    1 BD:    1 +.+.+.: strings

c1cfa5b8 FD:    1 BD:    1 +.+...: register_mutex

c1cfa198 FD:  144 BD:    2 +.+.+.: sound_mutex
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1cde990] req_lock
 -> [c1e098e4] &p->pi_lock
 -> [c25db718] (complete)&req.done
 -> [c1e0a8bc] &rq->lock
 -> [c25db710] &x->wait#5
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c25dfbc4] subsys mutex#38

c25dfbc4 FD:    8 BD:    5 +.+...: subsys mutex#38
 -> [c2607b50] &(&k->k_lock)->rlock

c1cfa6b8 FD:    1 BD:    1 +.+...: register_mutex#2

c1cfaed8 FD:  146 BD:    1 +.+.+.: register_mutex#3
 -> [c1cfa198] sound_mutex
 -> [c1cfaf10] clients_lock
 -> [c25bc904] &(&zone->lock)->rlock

c1cfaf10 FD:    1 BD:    4 ......: clients_lock

c25e09c0 FD:    2 BD:    1 +.+...: &client->ports_mutex
 -> [c25e09c8] &client->ports_lock

c25e09c8 FD:    1 BD:    2 .+.+..: &client->ports_lock

c1cfb078 FD:  147 BD:    1 +.+.+.: register_mutex#4
 -> [c1cfa478] sound_oss_mutex

c1cfa478 FD:  146 BD:    2 +.+.+.: sound_oss_mutex
 -> [c1cfa130] sound_loader_lock
 -> [c25db814] &x->wait#3
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1cde990] req_lock
 -> [c1e098e4] &p->pi_lock
 -> [c25db718] (complete)&req.done
 -> [c25db710] &x->wait#5
 -> [c1e0a8bc] &rq->lock
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c25dfbc4] subsys mutex#38

c1cfa130 FD:    1 BD:    3 +.+...: sound_loader_lock

c25e1160 FD:    4 BD:    1 ++++.+: &grp->list_mutex
 -> [c25e1168] &grp->list_lock
 -> [c1cfaf10] clients_lock
 -> [c1cfb1f0] register_lock#2

c25e1168 FD:    1 BD:    2 ......: &grp->list_lock

c1cfb100 FD:  147 BD:    1 +.+.+.: async_lookup_work
 -> [c1cfaf10] clients_lock
 -> [c1cfa258] snd_card_mutex
 -> [c1e0a8bc] &rq->lock
 -> [c1e0a1a5] &pool->lock/1
 -> [c1e0a0f0] (complete)&done#2
 -> [c1e0a0e8] &x->wait#12
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c1cfafa0] autoload_work
 -> [c1e0a1bc] (complete)&barr->done
 -> [c1e0a1cc] &x->wait#13

c1cfa258 FD:    1 BD:    2 +.+...: snd_card_mutex

c1e0a0f0 FD:  135 BD:    2 +.+...: (complete)&done#2
 -> [c1e0a0f8] (&sub_info->work)
 -> [c1e0a1a5] &pool->lock/1
 -> [c1e0a8bc] &rq->lock

c1e0a0e8 FD:    6 BD:    4 ......: &x->wait#12
 -> [c1e098e4] &p->pi_lock

c1cfb1f0 FD:    1 BD:    2 ......: register_lock#2

c1e098dc FD:    1 BD:   77 ......: &prev->lock

c25e3620 FD:    1 BD:    1 +.+...: &table[i].mutex

c1d021b8 FD:    1 BD:    1 +.+...: nf_log_mutex

c1cfafa0 FD:    8 BD:    7 +.+...: autoload_work
 -> [c2607b50] &(&k->k_lock)->rlock

c1e0a1bc FD:   15 BD:    6 +.+...: (complete)&barr->done
 -> [c1e0a1c4] (&barr->work)
 -> [c1e0a1a4] &(&pool->lock)->rlock
 -> [c1cfafa0] autoload_work
 -> [c1e0a8bc] &rq->lock
 -> [c1e0a1a5] &pool->lock/1

c1e0a1cc FD:    6 BD:   37 ......: &x->wait#13
 -> [c1e098e4] &p->pi_lock

c1e0a1c4 FD:    7 BD:    7 +.+...: (&barr->work)
 -> [c1e0a1cc] &x->wait#13

c1d02bb8 FD:    1 BD:    1 +.+...: nf_ct_ext_type_mutex

c1d02538 FD:    1 BD:    1 +.+...: nf_ct_helper_mutex

c25e3ad0 FD:    1 BD:    2 +.+.+.: &xt[i].mutex

c1d02238 FD:    1 BD:    1 +.+...: nf_sockopt_mutex

c1d02598 FD:    1 BD:    1 +.+.+.: nf_ct_proto_mutex

c1d06690 FD:    1 BD:    1 +.....: xfrm_km_lock

c1d06f50 FD:    1 BD:    1 +.....: inetsw6_lock

c1d07ab4 FD:    1 BD:    2 +.....: raw_v6_hashinfo.lock

c25efc40 FD:    1 BD:    2 +.+...: &(&ip6addrlbl_table.lock)->rlock

c25efb40 FD:    4 BD:    8 ++....: &ndev->lock
 -> [c1cd8790] random_write_wait.lock
 -> [c1cd85c8] nonblocking_pool.lock
 -> [c259f24c] &(&base->lock)->rlock

c25efcf2 FD:    1 BD:    8 +.....: &(&idev->mc_lock)->rlock

c25efd02 FD:    2 BD:    8 +.....: &(&mc->mca_lock)->rlock
 -> [c25e2048] _xmit_ETHER

c259f137 FD:    1 BD:    1 ......: rcu_read_lock_bh

c25e2048 FD:    1 BD:    9 +.....: _xmit_ETHER

c25efb20 FD:    1 BD:    1 .+.+..: "%s"("ipv6_addrconf")

c1d07000 FD:  108 BD:    1 +.+...: (addr_chk_work).work
 -> [c1cff938] rtnl_mutex

c1d06710 FD:    1 BD:    1 +.....: xfrm_type_lock

c1d08c78 FD:    1 BD:    1 +.+...: xfrm6_protocol_mutex

c1d066d0 FD:    1 BD:    1 +.....: xfrm_mode_lock

c26043d0 FD:    1 BD:    1 ......: &syncp->seq#2

c25efb28 FD:    1 BD:    1 ......: &syncp->seq#3

c1d05b98 FD:    1 BD:    1 +.+...: tunnel4_mutex

c1d0b450 FD:    1 BD:    1 +.+...: rpc_authflavor_lock

c1d0b6b0 FD:    1 BD:    1 +.+...: authtab_lock

c1c7e0b8 FD:   53 BD:    1 +.+.+.: microcode_mutex
 -> [c1cde52c] subsys mutex#3

c1cc3d78 FD:   10 BD:    1 +.+.+.: key_user_keyring_mutex
 -> [c1cc3b30] key_user_lock
 -> [c1cc3d08] root_key_user.lock
 -> [c1cd8790] random_write_wait.lock
 -> [c1cd85c8] nonblocking_pool.lock
 -> [c1cc3b70] key_serial_lock
 -> [c1cc3a78] key_construction_mutex
 -> [c1cc3c40] &type->lock_class

c1cc3d08 FD:    1 BD:    4 +.+...: root_key_user.lock

c1cc3c40 FD:    3 BD:    2 +.+.+.: &type->lock_class
 -> [c1cc3bd8] keyring_serialise_link_sem

c1cc3bd8 FD:    2 BD:    3 +.+.+.: keyring_serialise_link_sem
 -> [c1cc3d08] root_key_user.lock

c1ccb850 FD:    3 BD:    1 ......: lock#2
 -> [c1cd8790] random_write_wait.lock
 -> [c1cd85c8] nonblocking_pool.lock

c25db6c4 FD:    1 BD:    1 ++++..: "%s""deferwq"

c1cdde80 FD:    2 BD:    1 +.+...: deferred_probe_work
 -> [c1cddef8] deferred_probe_mutex

c1c9def0 FD:    9 BD:    2 ......: kernfs_notify_lock
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1c9dea0 FD:   37 BD:    1 +.+...: kernfs_notify_work
 -> [c1c9def0] kernfs_notify_lock
 -> [c1c9df90] kernfs_open_node_lock
 -> [c1c9de78] kernfs_mutex

c1c9df90 FD:    1 BD:   18 ......: kernfs_open_node_lock

c1ccff18 FD:    2 BD:    3 +.+.+.: performance_mutex
 -> [c25d57d4] semaphore->lock

c1cf5814 FD:    1 BD:    3 ......: cpufreq_driver_lock

c25df56c FD:    1 BD:    3 +.+...: &policy->rwsem

c1cf5558 FD:    1 BD:    3 +.+...: s_active#7

c1cf5654 FD:    1 BD:    3 +.+...: s_active#8

c1cf561c FD:    1 BD:    3 +.+...: s_active#9

c1cf5638 FD:    1 BD:    3 +.+...: s_active#10

c1cf5670 FD:    1 BD:    3 +.+...: s_active#11

c1cf568c FD:    1 BD:    3 +.+...: s_active#12

c1cf5574 FD:    1 BD:    3 +.+...: s_active#13

c1cf55ac FD:    1 BD:    3 +.+...: s_active#14

c1cf5590 FD:    1 BD:    3 +.+...: s_active#15

c1cf55c8 FD:    1 BD:    3 +.+...: s_active#16

c1cf553c FD:    1 BD:    3 +.+...: s_active#17

c25df544 FD:    1 BD:    3 ......: &x->wait#14

c25df554 FD:    1 BD:    3 +.+...: (complete)&policy->kobj_unregister

c1c87359 FD:    1 BD:    1 +.+...: pm_mutex/1

c1c999f0 FD:    1 BD:    3 +.+...: cdev_lock

c25d60ec FD:  193 BD:    2 +.+.+.: &tty->legacy_mutex
 -> [c1c972d0] vmap_area_lock
 -> [c25d60c4] &tty->write_wait
 -> [c25d60bc] &tty->read_wait
 -> [c25d60dc] &tty->termios_rwsem
 -> [c25d6094] &(&tty->files_lock)->rlock
 -> [c25d6228] &(&port->lock)->rlock
 -> [c25d6238] &port->mutex
 -> [c25d74d4] &port_lock_key
 -> [c1c87750] (console_sem).lock
 -> [c1c8772c] console_lock
 -> [c1c87710] logbuf_lock
 -> [c25c40d4] &(&f->f_lock)->rlock
 -> [c259f24c] &(&base->lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c259f254] ((&timer))
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25d60cc] &tty->ldisc_sem
 -> [c25d60a4] &(&tty->ctrl_lock)->rlock
 -> [c25d6248] &port->open_wait

c25d60c4 FD:    6 BD:   18 -.-...: &tty->write_wait
 -> [c1e098e4] &p->pi_lock

c25d60bc FD:    6 BD:    9 ......: &tty->read_wait
 -> [c1e098e4] &p->pi_lock

c25d60dc FD:  178 BD:    8 ++++..: &tty->termios_rwsem
 -> [c25d6238] &port->mutex
 -> [c25d60c4] &tty->write_wait
 -> [c25d60bc] &tty->read_wait
 -> [c25d6180] &ldata->output_lock
 -> [c25d74d4] &port_lock_key
 -> [c1c87750] (console_sem).lock
 -> [c1c8772c] console_lock
 -> [c1c87710] logbuf_lock
 -> [c1e0a8bc] &rq->lock
 -> [c1c7f3f0] pgd_lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25d609c] &(&tty->flow_lock)->rlock
 -> [c25d60e4] &tty->throttle_mutex
 -> [c255ba50] &sem->wait_lock
 -> [c25d60a4] &(&tty->ctrl_lock)->rlock

c25d6094 FD:    3 BD:    4 +.+...: &(&tty->files_lock)->rlock
 -> [c25c40d4] &(&f->f_lock)->rlock

c25d6228 FD:    1 BD:   12 ......: &(&port->lock)->rlock

c1cd4dd8 FD:   17 BD:   12 +.+.+.: hash_mutex
 -> [c259f0c4] &irq_desc_lock_class
 -> [c1c9dc14] proc_subdir_lock
 -> [c25c6f84] &(&ent->pde_unload_lock)->rlock
 -> [c1c9db90] proc_inum_lock
 -> [c25d7500] &(&i->lock)->rlock

c25d7500 FD:    8 BD:   13 -.-...: &(&i->lock)->rlock
 -> [c25d74d4] &port_lock_key

c1cf4930 FD:    1 BD:    4 +.+...: all_mddevs_lock

c25def0c FD:    1 BD:    1 +.+...: "md_misc"

c1cf4398 FD:  176 BD:    1 +.+.+.: disks_mutex
 -> [c1cc9300] (blk_queue_ida).idr.lock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1cc91d8] bio_slab_lock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1e0a16c] &wq->mutex
 -> [c1e0a8bc] &rq->lock
 -> [c1c82a10] kthread_create_lock
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a360] (complete)&done
 -> [c1e0a358] &x->wait
 -> [c1c827b8] wq_pool_mutex
 -> [c1ccb9d0] percpu_counters_lock
 -> [c25db814] &x->wait#3
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25def74] &mddev->open_mutex

c25def74 FD:  152 BD:    5 +.+.+.: &mddev->open_mutex
 -> [c25db814] &x->wait#3
 -> [c1cddc78] gdp_mutex
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c1ccd680] bus_type_sem
 -> [c1c9dfd0] sysfs_symlink_target_lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25db698] &(&dev->power.lock)->rlock
 -> [c1cdee58] dpm_list_mtx
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a1a5] &pool->lock/1
 -> [c1c820b0] running_helpers_waitq.lock
 -> [c1e0a8bc] &rq->lock
 -> [c25bcb50] subsys mutex#26
 -> [c1c99ff0] pin_fs_lock
 -> [c1cc30b4] &sb->s_type->i_mutex_key#3
 -> [c1c930d0] bdi_lock
 -> [c1ccaf18] block_class_lock
 -> [c1cde990] req_lock
 -> [c1e098e4] &p->pi_lock
 -> [c25db718] (complete)&req.done
 -> [c25db710] &x->wait#5
 -> [c25d280c] subsys mutex#27
 -> [c1cdedf8] dev_hotplug_mutex
 -> [c25d2718] &(&q->__queue_lock)->rlock

c25c57dc FD:  164 BD:    1 +.+.+.: &bdev->bd_fsfreeze_mutex
 -> [c1c99970] sb_lock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1c9e4c5] &type->s_umount_key#16/1
 -> [c1c9e545] &type->s_umount_key#17/1
 -> [c1c9e3c5] &type->s_umount_key#18/1

c1c9e4c5 FD:   64 BD:    2 +.+.+.: &type->s_umount_key#16/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25c5674] &(&mapping->private_lock)->rlock
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c1e0a8bc] &rq->lock

c25d2d60 FD:   24 BD:    1 +.+...: (&cfqd->unplug_work)
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock

c1c9e545 FD:   32 BD:    2 +.+.+.: &type->s_umount_key#17/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25c5674] &(&mapping->private_lock)->rlock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c1e0a8bc] &rq->lock

c1c9e3c5 FD:  161 BD:    2 +.+.+.: &type->s_umount_key#18/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25c5674] &(&mapping->private_lock)->rlock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c25bc924] zone->wait_table + i
 -> [c1cd8790] random_write_wait.lock
 -> [c1cd85c8] nonblocking_pool.lock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1ccb9d0] percpu_counters_lock
 -> [c1c63550] inode_hash_lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16
 -> [c1c9dbe0] (proc_inum_ida).idr.lock
 -> [c1c9db90] proc_inum_lock
 -> [c25c8744] &ei->i_data_sem
 -> [c25c8998] &journal->j_state_lock
 -> [c1ca6398] jbd2_slab_create_mutex
 -> [c25bc8fc] &(&zone->lru_lock)->rlock
 -> [c25c8954] &(&journal->j_revoke_lock)->rlock
 -> [c1c9c30c] &sb->s_type->i_lock_key#2
 -> [c25bcb38] &(&wb->list_lock)->rlock
 -> [c25bcb30] &(&wb->work_lock)->rlock
 -> [c25bc8c0] (PG_locked)page
 -> [c25d26c4] (complete)&ret.event
 -> [c25d26bc] &x->wait#15
 -> [c25ba114] &(&tsk->delays->lock)->rlock
 -> [c25c89b0] &journal->j_checkpoint_mutex
 -> [c1c82a10] kthread_create_lock
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a360] (complete)&done
 -> [c1e0a358] &x->wait
 -> [c25c89d8] &journal->j_wait_done_commit
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c1c827b8] wq_pool_mutex
 -> [c25cf500] &isec->lock
 -> [c1ca5df8] ext4_grpinfo_slab_create_mutex
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25c875c] &ext4_li_mtx
 -> [c25d2da8] &(&k->list_lock)->rlock
 -> [c25d2d9c] &(&idp->lock)->rlock
 -> [c1ccb5f0] simple_ida_lock
 -> [c1c9de78] kernfs_mutex
 -> [c25c89b8] &journal->j_barrier
 -> [c25c89e0] &journal->j_wait_transaction_locked
 -> [c259f24c] &(&base->lock)->rlock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c25c876c FD:    3 BD:    1 +.+...: &(&bgl->locks[i].lock)->rlock
 -> [c25c88c0] &(&sbi->s_bal_lock)->rlock
 -> [c25c88c8] &(&sbi->s_md_lock)->rlock

c1c9e3ec FD:   17 BD:  105 +.+...: &sb->s_type->i_lock_key#16
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25bcc48] &(&lru->node[i].lock)->rlock

c1b7b789 FD:    9 BD:    1 ..-...: fs/file_table.c:262
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1c99840 FD:  207 BD:    1 +.+...: (delayed_fput_work).work
 -> [c1e0a8bc] &rq->lock
 -> [c25c57e4] &bdev->bd_mutex

c25d2d68 FD:   20 BD:   62 +.-...: (&cfqd->idle_slice_timer)
 -> [c25d2718] &(&q->__queue_lock)->rlock

c25c41bc FD:    3 BD:    1 +.+...: (&s->destroy_work)
 -> [c259f150] &rsp->gp_wait
 -> [c1c934f0] pcpu_lock

c259f150 FD:    1 BD:    2 ......: &rsp->gp_wait

c25c878c FD:    5 BD:   63 ++++..: &ei->i_es_lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25c8920] &(&sbi->s_es_lock)->rlock
 -> [c25c8910] key#5
 -> [c25c8918] key#6

c25c8744 FD:   76 BD:   62 ++++..: &ei->i_data_sem
 -> [c25c878c] &ei->i_es_lock
 -> [c1e0a8bc] &rq->lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25c5674] &(&mapping->private_lock)->rlock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c25bc924] zone->wait_table + i
 -> [c25ba114] &(&tsk->delays->lock)->rlock
 -> [c25c8794] &(&ei->i_prealloc_lock)->rlock
 -> [c25c879c] &(&ei->i_raw_lock)->rlock
 -> [c25c89a0] &(&journal->j_list_lock)->rlock
 -> [c25c8954] &(&journal->j_revoke_lock)->rlock
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16
 -> [c25c8784] &(&(ei->i_block_reservation_lock))->rlock

c25c8920 FD:    1 BD:   64 +.+...: &(&sbi->s_es_lock)->rlock

c25c8998 FD:   31 BD:   16 ++++..: &journal->j_state_lock
 -> [c25c89d8] &journal->j_wait_done_commit
 -> [c25c89d0] &journal->j_wait_commit
 -> [c259f24c] &(&base->lock)->rlock
 -> [c25c8940] &(&transaction->t_handle_lock)->rlock
 -> [c25c89a0] &(&journal->j_list_lock)->rlock
 -> [c25c89e0] &journal->j_wait_transaction_locked

c1ca6398 FD:   71 BD:    3 +.+.+.: jbd2_slab_create_mutex

c25c8954 FD:    1 BD:   63 +.+...: &(&journal->j_revoke_lock)->rlock

c25bcb38 FD:   19 BD:   69 +.+...: &(&wb->list_lock)->rlock
 -> [c1c9c30c] &sb->s_type->i_lock_key#2
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16

c25bcb30 FD:    2 BD:   67 +.....: &(&wb->work_lock)->rlock
 -> [c259f24c] &(&base->lock)->rlock

c25d26c4 FD:    1 BD:    3 +.+...: (complete)&ret.event

c25d26bc FD:    6 BD:   81 ..-...: &x->wait#15
 -> [c1e098e4] &p->pi_lock

c25d2730 FD:   20 BD:    1 +.+...: (&(&q->delay_work)->work)
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbbe0] &(shost->host_lock)->rlock

c25c89b0 FD:   49 BD:    4 +.+...: &journal->j_checkpoint_mutex
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c25bc924] zone->wait_table + i
 -> [c1e0a8bc] &rq->lock
 -> [c25ba114] &(&tsk->delays->lock)->rlock
 -> [c25c8998] &journal->j_state_lock

c25c89d8 FD:    6 BD:   17 ......: &journal->j_wait_done_commit
 -> [c1e098e4] &p->pi_lock

c25c89d0 FD:    6 BD:   17 ......: &journal->j_wait_commit
 -> [c1e098e4] &p->pi_lock

c1ca5df8 FD:   71 BD:    3 +.+.+.: ext4_grpinfo_slab_create_mutex

c25c875c FD:    1 BD:    4 +.+...: &ext4_li_mtx

c25c89b8 FD:   52 BD:    3 +.+...: &journal->j_barrier
 -> [c25c8998] &journal->j_state_lock
 -> [c25c89a0] &(&journal->j_list_lock)->rlock
 -> [c25c89b0] &journal->j_checkpoint_mutex
 -> [c25c87c4] key
 -> [c25c87bc] key#2
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c25bc924] zone->wait_table + i
 -> [c1e0a8bc] &rq->lock
 -> [c25ba114] &(&tsk->delays->lock)->rlock

c25c89a0 FD:   26 BD:   66 +.+...: &(&journal->j_list_lock)->rlock
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c1c9c30c] &sb->s_type->i_lock_key#2
 -> [c25bcb38] &(&wb->list_lock)->rlock
 -> [c25bcb30] &(&wb->work_lock)->rlock

c25c87c4 FD:    1 BD:    5 ......: key

c25c87bc FD:    1 BD:    5 ......: key#2

c25c89e0 FD:    1 BD:   17 ......: &journal->j_wait_transaction_locked

c25c8764 FD:    1 BD:    1 ......: &rs->lock

c1c9e3fc FD:  121 BD:    4 ++++++: &type->i_mutex_dir_key
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25c8744] &ei->i_data_sem
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25c5674] &(&mapping->private_lock)->rlock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c25bc924] zone->wait_table + i
 -> [c1c63550] inode_hash_lock
 -> [c1e0a8bc] &rq->lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25ba114] &(&tsk->delays->lock)->rlock
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16
 -> [c25cf500] &isec->lock
 -> [c1c99eb8] namespace_sem
 -> [c25bc8fc] &(&zone->lru_lock)->rlock
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c1c7f3f0] pgd_lock
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25c8948] jbd2_handle

c1cde924 FD:   22 BD:    1 +.+...: &type->s_umount_key#19
 -> [c1c99970] sb_lock
 -> [c25bcc48] &(&lru->node[i].lock)->rlock
 -> [c25bca94] &(&sbinfo->stat_lock)->rlock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c25bcc48 FD:    1 BD:  174 +.+...: &(&lru->node[i].lock)->rlock

c25c45f8 FD:    6 BD:  173 ......: &wq#2
 -> [c1e098e4] &p->pi_lock

c1e09914 FD:  103 BD:    7 ++++++: &mm->mmap_sem
 -> [c25c3ce8] &anon_vma->rwsem
 -> [c1e0980c] &(ptlock_ptr(page))->rlock
 -> [c25c567c] &mapping->i_mmap_rwsem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1e0990c] &(&mm->page_table_lock)->rlock
 -> [c25c873c] &ei->i_mmap_sem
 -> [c25bc8fc] &(&zone->lru_lock)->rlock
 -> [c25bc8c0] (PG_locked)page
 -> [c25c3cdc] key#3
 -> [c1e09915] &mm->mmap_sem/1
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)
 -> [c25bc924] zone->wait_table + i
 -> [c25ba114] &(&tsk->delays->lock)->rlock

c25c874c FD:    1 BD:   12 .+.+..: &ei->xattr_sem

c1cd8710 FD:    1 BD:    1 ..-...: random_ready_list_lock

c1cd8750 FD:    1 BD:    1 ..-...: urandom_init_wait.lock

c1e0990c FD:    1 BD:   14 +.+...: &(&mm->page_table_lock)->rlock

c25c3ce8 FD:    4 BD:   13 +.+...: &anon_vma->rwsem
 -> [c1e0990c] &(&mm->page_table_lock)->rlock
 -> [c25c3cdc] key#3
 -> [c25bc904] &(&zone->lock)->rlock

c1e0980c FD:   10 BD:   70 +.+...: &(ptlock_ptr(page))->rlock
 -> [c1e0980d] &(ptlock_ptr(page))->rlock/1
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25bc8fc] &(&zone->lru_lock)->rlock
 -> [c25bc924] zone->wait_table + i

c1c9d554 FD:    1 BD:    1 .+.+..: entries_lock

c25c3cdc FD:    1 BD:   14 ......: key#3

c25c567c FD:   11 BD:    9 +.+...: &mapping->i_mmap_rwsem
 -> [c25c3ce8] &anon_vma->rwsem
 -> [c1e0a8bc] &rq->lock
 -> [c255ba50] &sem->wait_lock

c25c873c FD:   95 BD:    8 .+.+.+: &ei->i_mmap_sem
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25c8744] &ei->i_data_sem
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c25bc8c0] (PG_locked)page
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25bc8fc] &(&zone->lru_lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c25bc924] zone->wait_table + i
 -> [c25ba114] &(&tsk->delays->lock)->rlock
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c25c5674] &(&mapping->private_lock)->rlock
 -> [c1c7f3f0] pgd_lock

c1c82fb8 FD:    1 BD:    1 +.+...: reboot_mutex

c1cd17f0 FD:    1 BD:    1 ......: vt_spawn_con.lock

c25c40d4 FD:    2 BD:    7 +.+...: &(&f->f_lock)->rlock
 -> [c1c99b70] fasync_lock

c1c99b70 FD:    1 BD:    8 +.+...: fasync_lock

c25d60cc FD:  188 BD:    3 ++++++: &tty->ldisc_sem
 -> [c1c972d0] vmap_area_lock
 -> [c1cd0eb0] tty_ldiscs_lock
 -> [c25d6220] &buf->lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25d60dc] &tty->termios_rwsem
 -> [c25d60c4] &tty->write_wait
 -> [c25d60bc] &tty->read_wait
 -> [c25d74d4] &port_lock_key
 -> [c25d609c] &(&tty->flow_lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c25d6188] &ldata->atomic_read_lock
 -> [c25d6218] (&buf->work)
 -> [c1e0a1a5] &pool->lock/1
 -> [c1e0a1bc] (complete)&barr->done
 -> [c1e0a1cc] &x->wait#13

c25d608c FD:    1 BD:    1 +.+...: (&tty->SAK_work)

c25d60b4 FD:    1 BD:    1 +.+...: (&tty->hangup_work)

c25d6218 FD:  180 BD:    5 +.+...: (&buf->work)

c25d60f4 FD:    4 BD:    1 +.+...: (&tty->hangup_work)#2
 -> [c25d6094] &(&tty->files_lock)->rlock

c25d6220 FD:  179 BD:    6 +.+...: &buf->lock
 -> [c25d60dc] &tty->termios_rwsem

c25d6240 FD:    1 BD:   12 ......: &port->delta_msr_wait

c25d7508 FD:    1 BD:   12 ......: (&up->timer)

c25d6248 FD:    1 BD:   12 ......: &port->open_wait

c1c9e3d4 FD:  124 BD:    1 .+.+.+: sb_writers#3
 -> [c1e0a8bc] &rq->lock
 -> [c25c8948] jbd2_handle
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16
 -> [c25bcb38] &(&wb->list_lock)->rlock
 -> [c1c9e3fd] &type->i_mutex_dir_key/1
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25bc8fc] &(&zone->lru_lock)->rlock
 -> [c1c63550] inode_hash_lock
 -> [c25cf4f0] &(&sbsec->isec_lock)->rlock
 -> [c1c9e3fc] &type->i_mutex_dir_key
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1c9e3f4] &sb->s_type->i_mutex_key#8

c1cd0cf0 FD:    1 BD:    1 +.+...: redirect_lock

c25d60ac FD:  179 BD:    1 +.+.+.: &tty->atomic_write_lock
 -> [c25d60dc] &tty->termios_rwsem
 -> [c255ba50] &sem->wait_lock

c25d6180 FD:   69 BD:    9 +.+...: &ldata->output_lock
 -> [c25d74d4] &port_lock_key
 -> [c1c87750] (console_sem).lock
 -> [c1c8772c] console_lock
 -> [c1c87710] logbuf_lock
 -> [c1e0a8bc] &rq->lock

c1dfe42c FD:    1 BD:    7 +.+...: &mm->context.lock

c1e09915 FD:   17 BD:    8 +.+.+.: &mm->mmap_sem/1
 -> [c25c567c] &mapping->i_mmap_rwsem
 -> [c25c3ce8] &anon_vma->rwsem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1e0990c] &(&mm->page_table_lock)->rlock
 -> [c1e0980c] &(ptlock_ptr(page))->rlock
 -> [c25c3cdc] key#3
 -> [c1e0a8bc] &rq->lock
 -> [c1c7f3f0] pgd_lock

c1e0980d FD:    1 BD:   71 +.+...: &(ptlock_ptr(page))->rlock/1

c25c45e9 FD:   13 BD:    1 +.+.+.: &pipe->mutex/1
 -> [c25c45f0] &pipe->wait
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1e0a8bc] &rq->lock

c25c45f0 FD:    7 BD:    4 ......: &pipe->wait
 -> [c1e098e4] &p->pi_lock
 -> [c25c5980] &(&ep->lock)->rlock

c25d60a4 FD:    1 BD:   77 ......: &(&tty->ctrl_lock)->rlock

c1c81f98 FD:    2 BD:    1 ++++..: uts_sem
 -> [c1c8d154] hostname_poll.wait.lock

c1c9e3f4 FD:  110 BD:    5 +.+.+.: &sb->s_type->i_mutex_key#8
 -> [c25c5674] &(&mapping->private_lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25c8948] jbd2_handle
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25c874c] &ei->xattr_sem
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25bc8c0] (PG_locked)page
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16
 -> [c25bcb38] &(&wb->list_lock)->rlock
 -> [c25bcb30] &(&wb->work_lock)->rlock

c1c9e3fd FD:  111 BD:    2 +.+...: &type->i_mutex_dir_key/1
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1c9e3f4] &sb->s_type->i_mutex_key#8
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16

c1c9db24 FD:   21 BD:    1 +.+...: &type->s_umount_key#20
 -> [c1c99970] sb_lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c25d2775 FD:    2 BD:    2 ......: &(&ioc->lock)->rlock/1

c25d276c FD:    3 BD:    1 +.+...: (&ioc->release_work)
 -> [c25d2775] &(&ioc->lock)->rlock/1

c25c5780 FD:   85 BD:    3 +.+.+.: &p->lock
 -> [c1c99eb8] namespace_sem
 -> [c1c99a58] chrdevs_lock
 -> [c1ccaf18] block_class_lock
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c1e098a4] &(&sighand->siglock)->rlock
 -> [c25ba114] &(&tsk->delays->lock)->rlock
 -> [c25c8090] &of->mutex
 -> [c1c635d0] bdev_lock
 -> [c1c98e70] swap_lock
 -> [c1e0a8bc] &rq->lock

c1cd87d0 FD:    1 BD:   87 -.-...: random_read_wait.lock

c1c9db34 FD:   50 BD:    1 .+.+.+: sb_writers#4
 -> [c1c9db4c] &sb->s_type->i_lock_key#4
 -> [c1c9db54] &sb->s_type->i_mutex_key
 -> [c1c9dc50] sysctl_lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1e098f4] &(&p->alloc_lock)->rlock

c1c9e025 FD:   37 BD:    1 +.+.+.: &type->s_umount_key#21/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c1c9de78] kernfs_mutex
 -> [c25cf500] &isec->lock
 -> [c1c9e04c] &sb->s_type->i_lock_key#17
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1c9e04c FD:   17 BD:   82 +.+...: &sb->s_type->i_lock_key#17
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1c9e05c FD:   43 BD:    1 ++++++: &type->i_mutex_dir_key#2
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1c9de78] kernfs_mutex
 -> [c1c99eb8] namespace_sem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c1e098e4] &p->pi_lock

c1cc3084 FD:   21 BD:    1 +.+...: &type->s_umount_key#22
 -> [c1c99970] sb_lock
 -> [c25bcc48] &(&lru->node[i].lock)->rlock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c25c4629 FD:    2 BD:  173 +.+...: &(&dentry->d_lockref.lock)->rlock/1
 -> [c25bcc48] &(&lru->node[i].lock)->rlock

c1c92e74 FD:  115 BD:    2 .+.+.+: sb_writers#5
 -> [c1c92e95] &sb->s_type->i_mutex_key#9/1
 -> [c1c92e94] &sb->s_type->i_mutex_key#10
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1c92e8c] &sb->s_type->i_lock_key#5
 -> [c1e0a8bc] &rq->lock
 -> [c255ba50] &sem->wait_lock

c1c92e95 FD:  114 BD:    3 +.+.+.: &sb->s_type->i_mutex_key#9/1
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25bca94] &(&sbinfo->stat_lock)->rlock
 -> [c1c92e8c] &sb->s_type->i_lock_key#5
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25efa68] &u->readlock
 -> [c1c92e98] &sb->s_type->i_mutex_key#10/4
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c92e94] &sb->s_type->i_mutex_key#10
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25bc8fc] &(&zone->lru_lock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c25bca84] &(&info->lock)->rlock
 -> [c25cf4f0] &(&sbsec->isec_lock)->rlock
 -> [c255ba50] &sem->wait_lock

c1c92e94 FD:  105 BD:    4 ++++++: &sb->s_type->i_mutex_key#10
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25bca94] &(&sbinfo->stat_lock)->rlock
 -> [c1c92e8c] &sb->s_type->i_lock_key#5
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25bca7c] &(&xattrs->lock)->rlock
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25bca84] &(&info->lock)->rlock
 -> [c25c566c] &inode->i_size_seqcount
 -> [c25bc8c0] (PG_locked)page
 -> [c1c92e98] &sb->s_type->i_mutex_key#10/4
 -> [c1e0a8bc] &rq->lock
 -> [c255ba50] &sem->wait_lock
 -> [c25b4244] &(kretprobe_table_locks[i].lock)
 -> [c25bc8fc] &(&zone->lru_lock)->rlock

c25bca7c FD:    1 BD:   41 +.+...: &(&xattrs->lock)->rlock

c25bca84 FD:    1 BD:   62 +.+...: &(&info->lock)->rlock

c1c99b14 FD:    1 BD:    1 .+.+..: sb_writers#6

c25c40cc FD:  154 BD:    1 +.+.+.: &f->f_pos_lock
 -> [c1cde934] sb_writers
 -> [c1c92e74] sb_writers#5
 -> [c1e0a8bc] &rq->lock
 -> [c25c5780] &p->lock

c25bca40 FD:    4 BD:    1 +.-...: (&dom->period_timer)
 -> [c25d2d94] key#4
 -> [c25d2d8c] &p->sequence
 -> [c259f24c] &(&base->lock)->rlock

c25d2d94 FD:    1 BD:    2 ..-...: key#4

c25d2d8c FD:    1 BD:    2 ..-...: &p->sequence

c25c6f7c FD:    1 BD:  173 ......: &wq#3

c1d06dd0 FD:    1 BD:    7 +.+...: unix_table_lock

c25efa68 FD:   31 BD:    6 +.+.+.: &u->readlock
 -> [c25bca94] &(&sbinfo->stat_lock)->rlock
 -> [c1c92e8c] &sb->s_type->i_lock_key#5
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1d06dd0] unix_table_lock
 -> [c25efa78] &af_unix_sk_receive_queue_lock_key
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1cde94c] &sb->s_type->i_lock_key#6
 -> [c25efa60] &u->peer_wait

c25efa70 FD:   21 BD:    1 +.+...: &(&u->lock)->rlock
 -> [c25e1728] clock-AF_UNIX
 -> [c25efa71] &(&u->lock)->rlock/1
 -> [c25efa78] &af_unix_sk_receive_queue_lock_key
 -> [c25efa60] &u->peer_wait

c1c82c70 FD:    7 BD:    1 .+.+.+: s_active#18
 -> [c1c9df58] kernfs_open_file_mutex

c1c9df58 FD:    6 BD:   16 +.+...: kernfs_open_file_mutex
 -> [c1c9df90] kernfs_open_node_lock
 -> [c1e0a8bc] &rq->lock

c25c8090 FD:   40 BD:    5 +.+.+.: &of->mutex

c1c92e98 FD:   19 BD:    5 +.+...: &sb->s_type->i_mutex_key#10/4
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1c63528] rename_lock

c25c462a FD:    4 BD:  173 +.+...: &(&dentry->d_lockref.lock)->rlock/2
 -> [c25c462b] &(&dentry->d_lockref.lock)->rlock/3

c25c462b FD:    3 BD:  174 +.+...: &(&dentry->d_lockref.lock)->rlock/3
 -> [c25c4620] &dentry->d_seq

c25c4621 FD:    1 BD:  176 +.+...: &dentry->d_seq/1

c25e1728 FD:    1 BD:    2 +.....: clock-AF_UNIX

c25efa60 FD:    6 BD:    8 +.+...: &u->peer_wait
 -> [c1e098e4] &p->pi_lock

c25efa78 FD:    1 BD:    8 +.+...: &af_unix_sk_receive_queue_lock_key

c25efa71 FD:   17 BD:    2 +.+...: &(&u->lock)->rlock/1
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c25e1680 FD:    7 BD:   71 ......: &wq->wait
 -> [c1e098e4] &p->pi_lock
 -> [c25c5980] &(&ep->lock)->rlock

c25c8910 FD:    1 BD:   64 ......: key#5

c25c8918 FD:    1 BD:   64 ......: key#6

c25c5978 FD:   32 BD:    2 +.+.+.: &ep->mtx
 -> [c25e1680] &wq->wait
 -> [c25c40d4] &(&f->f_lock)->rlock
 -> [c25c5980] &(&ep->lock)->rlock
 -> [c25c5834] &group->notification_waitq
 -> [c25c583c] &group->notification_mutex
 -> [c1e0989c] &sighand->signalfd_wqh
 -> [c1e098a4] &(&sighand->siglock)->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c25c45f0] &pipe->wait

c25c5980 FD:    6 BD:  106 ......: &(&ep->lock)->rlock
 -> [c1e098e4] &p->pi_lock

c25c5834 FD:    1 BD:    3 ......: &group->notification_waitq

c25c583c FD:    1 BD:    3 +.+...: &group->notification_mutex

c1e0989c FD:    7 BD:   77 ......: &sighand->signalfd_wqh
 -> [c25c5980] &(&ep->lock)->rlock

c1c98e70 FD:    1 BD:    4 +.+...: swap_lock

c25e1888 FD:    1 BD:    2 +.....: slock-AF_UNIX

c25e19e8 FD:    2 BD:    1 +.+...: sk_lock-AF_UNIX
 -> [c25e1888] slock-AF_UNIX

c1c9e034 FD:   42 BD:    1 .+.+.+: sb_writers#7
 -> [c1c9e04c] &sb->s_type->i_lock_key#17
 -> [c25bcb38] &(&wb->list_lock)->rlock
 -> [c25c8090] &of->mutex
 -> [c1e0a8bc] &rq->lock

c25e1d68 FD:    1 BD:   65 ......: &(&net->nsid_lock)->rlock

c25e16dc FD:    1 BD:   65 ..-...: &(&list->lock)->rlock

c25e2a20 FD:    1 BD:    1 ......: &nlk->wait

c1cddce4 FD:   42 BD:    1 .+.+.+: s_active#19
 -> [c1c9df58] kernfs_open_file_mutex
 -> [c1ccb6d8] uevent_sock_mutex
 -> [c1e0a8bc] &rq->lock
 -> [c1e098e4] &p->pi_lock
 -> [c25d5adc] &device->physical_node_lock
 -> [c25bc904] &(&zone->lock)->rlock

c25bcb20 FD:    9 BD:    1 ..-...: (&(&wb->dwork)->timer)
 -> [c1e0a1a5] &pool->lock/1

c25bcb48 FD:    1 BD:    1 .+.+.+: "writeback"

c25bcb28 FD:  111 BD:    1 +.+.+.: (&(&wb->dwork)->work)
 -> [c25bcb30] &(&wb->work_lock)->rlock
 -> [c25bcb38] &(&wb->list_lock)->rlock
 -> [c25d2d74] &pl->lock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock

c25d2d74 FD:    2 BD:   70 ..-...: &pl->lock
 -> [c25d2d7c] key#7

c25d2d7c FD:    1 BD:   71 ..-...: key#7

c1cf0bb4 FD:    7 BD:    1 .+.+.+: s_active#20
 -> [c1c9df58] kernfs_open_file_mutex

c1cf0b60 FD:    7 BD:    1 .+.+.+: s_active#21
 -> [c1c9df58] kernfs_open_file_mutex

c1cf0b7c FD:    7 BD:    1 .+.+.+: s_active#22
 -> [c1c9df58] kernfs_open_file_mutex

c1cf0b98 FD:    8 BD:    1 .+.+.+: s_active#23
 -> [c1c9df58] kernfs_open_file_mutex
 -> [c1e098e4] &p->pi_lock
 -> [c1e0a8bc] &rq->lock

c1cf0d04 FD:    7 BD:    1 .+.+.+: s_active#24
 -> [c1c9df58] kernfs_open_file_mutex

c1cf630c FD:    8 BD:    1 .+.+.+: s_active#25
 -> [c1c9df58] kernfs_open_file_mutex
 -> [c1e098e4] &p->pi_lock

c255ba50 FD:    6 BD:   22 ......: &sem->wait_lock
 -> [c1e098e4] &p->pi_lock

c25c40c0 FD:    1 BD:    1 ......: key#8

c25c582c FD:   22 BD:    1 +.+.+.: &group->mark_mutex
 -> [c1c92e8c] &sb->s_type->i_lock_key#5
 -> [c1e0a8bc] &rq->lock
 -> [c25c5944] &(&group->inotify_data.idr_lock)->rlock
 -> [c25c5938] &(&mark->lock)->rlock
 -> [c1cde94c] &sb->s_type->i_lock_key#6
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16

c25c5944 FD:    1 BD:    2 +.+...: &(&group->inotify_data.idr_lock)->rlock

c25c5938 FD:   20 BD:    3 +.+...: &(&mark->lock)->rlock
 -> [c1c92e8c] &sb->s_type->i_lock_key#5
 -> [c1cde94c] &sb->s_type->i_lock_key#6
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16

c1ce39ec FD:    7 BD:    1 .+.+.+: s_active#26
 -> [c1e0a8bc] &rq->lock
 -> [c1c9df58] kernfs_open_file_mutex

c1ccc62c FD:    7 BD:    1 .+.+.+: s_active#27
 -> [c1c9df58] kernfs_open_file_mutex

c1ce3a24 FD:    7 BD:    1 .+.+.+: s_active#28
 -> [c1c9df58] kernfs_open_file_mutex

c1ccc610 FD:    7 BD:    1 .+.+.+: s_active#29
 -> [c1c9df58] kernfs_open_file_mutex

c1c9c538 FD:   33 BD:    1 +.+...: epmutex
 -> [c1e0a8bc] &rq->lock
 -> [c25c5978] &ep->mtx

c1ce47f8 FD:   86 BD:    4 +.+.+.: sr_mutex
 -> [c1ce4698] sr_ref_mutex
 -> [c1e0a8bc] &rq->lock
 -> [c25d2824] &ev->block_mutex
 -> [c25d282c] &(&ev->lock)->rlock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c25d2788] (complete)&wait
 -> [c25d2780] &x->wait#10
 -> [c25ba114] &(&tsk->delays->lock)->rlock
 -> [c1c99970] sb_lock
 -> [c25dbbd8] &shost->host_wait
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25dbbe0] &(shost->host_lock)->rlock
 -> [c1e098f4] &(&p->alloc_lock)->rlock

c1ce4698 FD:    1 BD:    5 +.+...: sr_ref_mutex

c1cf1a28 FD:    7 BD:    1 .+.+.+: s_active#30
 -> [c1c9df58] kernfs_open_file_mutex

c25d2728 FD:    9 BD:    1 ..-...: (&(&q->delay_work)->timer)
 -> [c1e0a1a4] &(&pool->lock)->rlock

c25c582d FD:   21 BD:    1 +.+...: &group->mark_mutex/1
 -> [c25c5938] &(&mark->lock)->rlock

c1c9c3d0 FD:    1 BD:    1 +.+...: destroy_lock

c259f178 FD:    1 BD:    1 ......: &(&sp->queue_lock)->rlock

c1c9e3c4 FD:  117 BD:    1 ++++.+: &type->s_umount_key#23
 -> [c25bcc48] &(&lru->node[i].lock)->rlock
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16
 -> [c25c8998] &journal->j_state_lock
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c25c87c4] key
 -> [c25c87bc] key#2
 -> [c1e0a8bc] &rq->lock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25dbfa8] &(&host->lock)->rlock
 -> [c25bc924] zone->wait_table + i
 -> [c25ba114] &(&tsk->delays->lock)->rlock
 -> [c25c875c] &ext4_li_mtx
 -> [c1c635a8] mount_lock
 -> [c25c87a4] &sbi->s_journal_flag_rwsem
 -> [c25bcb38] &(&wb->list_lock)->rlock

c25c8948 FD:  109 BD:   11 +.+...: jbd2_handle
 -> [c25c89a0] &(&journal->j_list_lock)->rlock
 -> [c25c8954] &(&journal->j_revoke_lock)->rlock
 -> [c25c5674] &(&mapping->private_lock)->rlock
 -> [c25c89c8] &journal->j_wait_updates
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25c879c] &(&ei->i_raw_lock)->rlock
 -> [c25c8998] &journal->j_state_lock
 -> [c25c87d4] &sbi->s_orphan_lock
 -> [c25c8744] &ei->i_data_sem
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c25c8794] &(&ei->i_prealloc_lock)->rlock
 -> [c25c878c] &ei->i_es_lock
 -> [c25c88d0] &meta_group_info[i]->alloc_sem
 -> [c1c63550] inode_hash_lock
 -> [c25c87e4] &(&sbi->s_next_gen_lock)->rlock
 -> [c25c874c] &ei->xattr_sem
 -> [c1c9e3ec] &sb->s_type->i_lock_key#16
 -> [c25cf500] &isec->lock
 -> [c25bc8c0] (PG_locked)page
 -> [c25bcb38] &(&wb->list_lock)->rlock
 -> [c25c566c] &inode->i_size_seqcount
 -> [c25bc8fc] &(&zone->lru_lock)->rlock

c25c89c8 FD:    1 BD:   12 ......: &journal->j_wait_updates

c1cde958 FD:   19 BD:   38 +.+...: &sb->s_type->i_mutex_key#5/4
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1c63528] rename_lock

c1ce3a08 FD:    8 BD:    1 .+.+.+: s_active#31
 -> [c1c9df58] kernfs_open_file_mutex
 -> [c1e098e4] &p->pi_lock

c1ccadfc FD:    7 BD:    1 .+.+.+: s_active#32
 -> [c1c9df58] kernfs_open_file_mutex
 -> [c1e0a8bc] &rq->lock

c25e17a0 FD:    1 BD:    1 +.....: clock-AF_NETLINK

c25d2de5 FD:   15 BD:    1 +.+.+.: (&ht->run_work)
 -> [c25d2df5] &ht->mutex

c25d2df5 FD:   14 BD:    2 +.+.+.: &ht->mutex
 -> [c1e0a8bc] &rq->lock
 -> [c1cd8790] random_write_wait.lock
 -> [c1cd85c8] nonblocking_pool.lock
 -> [c25d2dfd] &(&tbl->locks[i])->rlock
 -> [c25d2ded] &(&ht->lock)->rlock

c25d2dfe FD:    1 BD:    6 +.....: &(&tbl->locks[i])->rlock/1

c25d2ded FD:    1 BD:    3 +.+...: &(&ht->lock)->rlock

c25dbab8 FD:    7 BD:    4 +.+...: &lo->lo_ctl_mutex
 -> [c1e0a8bc] &rq->lock
 -> [c25d2710] &q->mq_freeze_wq

c25d2710 FD:    6 BD:    5 ..-...: &q->mq_freeze_wq
 -> [c1e098e4] &p->pi_lock

c1ccb8f0 FD:    1 BD:    1 ..-...: percpu_ref_switch_waitq.lock

c25e24d4 FD:    9 BD:    1 ..-...: (&(&tbl->gc_work)->timer)
 -> [c1e0a1a4] &(&pool->lock)->rlock

c25e24dc FD:    3 BD:    1 +.+...: (&(&tbl->gc_work)->work)
 -> [c25e24e4] &tbl->lock

c25c879c FD:    1 BD:   63 +.+...: &(&ei->i_raw_lock)->rlock

c25c8988 FD:    6 BD:    1 +.-...: ((&journal->j_commit_timer))
 -> [c1e098e4] &p->pi_lock

c25c8940 FD:    1 BD:   17 +.+...: &(&transaction->t_handle_lock)->rlock

c25c88c8 FD:    1 BD:   64 +.+...: &(&sbi->s_md_lock)->rlock

c25c8990 FD:    1 BD:    1 +.+...: &(&journal->j_history_lock)->rlock

c25c87d4 FD:    1 BD:   12 +.+...: &sbi->s_orphan_lock

c1c9e3e4 FD:  110 BD:    1 .+.+..: sb_internal
 -> [c25c8948] jbd2_handle

c25c8794 FD:    1 BD:   63 +.+...: &(&ei->i_prealloc_lock)->rlock

c25c88c0 FD:    1 BD:   64 +.+...: &(&sbi->s_bal_lock)->rlock

c25c88d0 FD:    1 BD:   12 .+.+..: &meta_group_info[i]->alloc_sem

c25c87e4 FD:    1 BD:   12 +.+...: &(&sbi->s_next_gen_lock)->rlock

c25c8784 FD:    1 BD:   63 +.+...: &(&(ei->i_block_reservation_lock))->rlock

c1c9e0a5 FD:   27 BD:    1 +.+.+.: &type->s_umount_key#24/1
 -> [c1c99970] sb_lock
 -> [c1c90a18] shrinker_rwsem
 -> [c1c9e0cc] &sb->s_type->i_lock_key#18
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock
 -> [c1c9e0d4] &sb->s_type->i_mutex_key#11
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c25cf4f8] &sbsec->lock

c1c9e0cc FD:   17 BD:    3 +.+...: &sb->s_type->i_lock_key#18
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock

c1c9e0d4 FD:   21 BD:    2 +.+.+.: &sb->s_type->i_mutex_key#11
 -> [c25c4628] &(&dentry->d_lockref.lock)->rlock
 -> [c1c9e0cc] &sb->s_type->i_lock_key#18
 -> [c25c41a4] &(&s->s_inode_list_lock)->rlock
 -> [c25cf500] &isec->lock

c255e580 FD:    2 BD:    1 +.+...: &user->lock
 -> [c1c87710] logbuf_lock

c1c9c2e4 FD:   94 BD:    1 .+.+..: &type->s_umount_key#25
 -> [c1c9c30c] &sb->s_type->i_lock_key#2
 -> [c25bc8c0] (PG_locked)page
 -> [c25c5684] &(&mapping->tree_lock)->rlock
 -> [c1e098f4] &(&p->alloc_lock)->rlock
 -> [c25d2718] &(&q->__queue_lock)->rlock
 -> [c25bc8fc] &(&zone->lru_lock)->rlock
 -> [c25bcb38] &(&wb->list_lock)->rlock
 -> [c25bc904] &(&zone->lock)->rlock

c1c8d154 FD:    1 BD:    2 ......: hostname_poll.wait.lock

c25dec04 FD:    1 BD:    1 ......: &(&rtc->irq_lock)->rlock

c25debfc FD:    1 BD:    1 ......: &(&rtc->irq_task_lock)->rlock

c25c5ac0 FD:    2 BD:    1 +.+...: &(&ctx->flc_lock)->rlock
 -> [c1c9c724] file_lock_lglock

c1c9c724 FD:    1 BD:    2 .+.+..: file_lock_lglock

c1e098b4 FD:  142 BD:    1 +.+...: (complete)&vfork
 -> [c1e098bc] &sig->cred_guard_mutex
 -> [c1e0980c] &(ptlock_ptr(page))->rlock
 -> [c1e0a8bc] &rq->lock
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c1c7f3f0] pgd_lock

c1e098ac FD:    6 BD:   73 ......: &x->wait#16
 -> [c1e098e4] &p->pi_lock

c1d047d8 FD:    5 BD:    8 .+.+.+: (inetaddr_chain).rwsem
 -> [c1d04a90] fib_info_lock
 -> [c1c934b8] pcpu_alloc_mutex
 -> [c1d01e50] nl_table_wait.lock

c1d04a90 FD:    1 BD:    9 +.....: fib_info_lock

c25e2148 FD:    1 BD:    8 +.....: _xmit_LOOPBACK

c1d005e4 FD:    1 BD:    1 ......: netpoll_srcu

c25ee798 FD:    1 BD:    8 +.....: &(&in_dev->mc_tomb_lock)->rlock

c1d07090 FD:    2 BD:    8 +.....: addrconf_hash_lock
 -> [c1c934f0] pcpu_lock

c25efb58 FD:    1 BD:    8 +.....: &(&ifa->lock)->rlock

c25efca0 FD:    3 BD:    8 +.....: &tb->tb6_lock
 -> [c1d01e50] nl_table_wait.lock
 -> [c25efcb0] &net->ipv6.fib6_walker_lock

c25efcb0 FD:    1 BD:    9 +.....: &net->ipv6.fib6_walker_lock

c25e1890 FD:    1 BD:    1 +.....: slock-AF_INET

c25e1730 FD:    1 BD:    1 +.....: clock-AF_INET

c1c876d0 FD:    6 BD:    1 -.....: log_wait.lock
 -> [c1e098e4] &p->pi_lock

c25d609c FD:    1 BD:    9 ......: &(&tty->flow_lock)->rlock

c25d6188 FD:  185 BD:    4 +.+...: &ldata->atomic_read_lock
 -> [c25d60dc] &tty->termios_rwsem
 -> [c25d6218] (&buf->work)
 -> [c1e0a8bc] &rq->lock
 -> [c1c7f3f0] pgd_lock
 -> [c25d60bc] &tty->read_wait
 -> [c1e0a1a5] &pool->lock/1
 -> [c1e0a1bc] (complete)&barr->done
 -> [c1e0a1cc] &x->wait#13

c1b8863b FD:    5 BD:    1 +.-...: lib/random32.c:217
 -> [c1cd8790] random_write_wait.lock
 -> [c1cd85c8] nonblocking_pool.lock
 -> [c259f24c] &(&base->lock)->rlock
 -> [c1cd86c8] input_pool.lock

c1b50661 FD:    9 BD:    1 ..-...: arch/x86/kernel/check.c:145
 -> [c1e0a1a4] &(&pool->lock)->rlock

c25c87a4 FD:  110 BD:    3 .+.+.+: &sbi->s_journal_flag_rwsem
 -> [c25bc904] &(&zone->lock)->rlock
 -> [c25c8948] jbd2_handle
 -> [c25d2718] &(&q->__queue_lock)->rlock

c1cd25a0 FD:   69 BD:    1 +.+...: console_work
 -> [c1c87750] (console_sem).lock
 -> [c1c8772c] console_lock
 -> [c1c87710] logbuf_lock
 -> [c1e0a8bc] &rq->lock

c25d60e4 FD:    1 BD:    9 +.+...: &tty->throttle_mutex

c25d60d4 FD:    1 BD:    1 +.+...: &tty->winsize_mutex

c1c003d1 FD:    9 BD:    1 ..-...: net/wireless/reg.c:212
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1d0c440 FD:  108 BD:    1 +.+...: (reg_check_chans).work
 -> [c1cff938] rtnl_mutex

c1bfe51f FD:    9 BD:    1 ..-...: net/ipv6/addrconf.c:150
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1bfc462 FD:    9 BD:    1 ..-...: net/ipv4/devinet.c:438
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1e0a19c FD:   10 BD:    1 +.-...: (&pool->idle_timer)
 -> [c1e0a1a5] &pool->lock/1
 -> [c1e0a1a4] &(&pool->lock)->rlock

c25c87dc FD:    2 BD:    1 +.-...: ((&sbi->s_err_report))
 -> [c259f24c] &(&base->lock)->rlock

c25e28ec FD:    2 BD:    1 +.-...: ((&fc->rnd_timer))
 -> [c259f24c] &(&base->lock)->rlock

c1b956b4 FD:    9 BD:   12 +.-...: drivers/tty/vt/vt.c:231
 -> [c1e0a1a4] &(&pool->lock)->rlock

c1cd1250 FD:    1 BD:   12 ......: vt_event_lock

c1b95555 FD:    1 BD:   12 +.-...: drivers/tty/vt/keyboard.c:252

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
