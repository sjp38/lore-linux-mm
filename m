Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id BA7C36B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 08:15:13 -0500 (EST)
Received: by mail-ie0-f177.google.com with SMTP id tp5so17682898ieb.8
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 05:15:13 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id ot3si54823750pac.340.2014.01.06.05.15.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 05:15:12 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 6 Jan 2014 18:45:07 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id B06D9E0056
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 18:47:48 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s06DEw9x28442800
	for <linux-mm@kvack.org>; Mon, 6 Jan 2014 18:44:58 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s06DF2of012609
	for <linux-mm@kvack.org>; Mon, 6 Jan 2014 18:45:02 +0530
Date: Mon, 6 Jan 2014 21:15:01 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
Message-ID: <52caac60.e3d8420a.7d5f.fffff93dSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20130427112418.GC4441@localhost.localdomain>
 <0000013e5645b356-09aa6796-0a95-40f1-8ec5-6e2e3d0c434f-000000@email.amazonses.com>
 <20130429145711.GC1172@dhcp22.suse.cz>
 <20130502105637.GD4441@localhost.localdomain>
 <0000013e65cb32b3-047cd2d6-dfc8-41d2-a792-9b398f9a1baf-000000@email.amazonses.com>
 <20130503030345.GE4441@localhost.localdomain>
 <0000013e6aff6f95-b8fa366e-51a5-4632-962e-1b990520f5a8-000000@email.amazonses.com>
 <20130503153450.GA18709@dhcp22.suse.cz>
 <0000013e6b2e06ab-a26ffcc5-a52d-4165-9be0-025ae813da00-000000@email.amazonses.com>
 <52bd58da.2501440a.6368.16ddSMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52bd58da.2501440a.6368.16ddSMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@suse.cz>, Han Pingtian <hanpt@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Fri, Dec 27, 2013 at 06:39:12PM +0800, Wanpeng Li wrote:
>Hi Christoph,
>On Fri, May 03, 2013 at 04:16:18PM +0000, Christoph Lameter wrote:
>>On Fri, 3 May 2013, Michal Hocko wrote:
>>
>>> > Both should be fixed.
>>>
>>> Could you point to the specific commit(s), please?
>>>
>>> > Making requests for large amounts of memory from an allocator that is
>>> > supposed to hand out fraction of a page does not make sense.
>>>
>>> AFAIR there were lots of objects in size-512 as well.
>>
>>Looks like I have confused two different issues here. Sorry.
>>
>
>Is there any progress against slub's fix?
>
>MemTotal:        7760960 kB
>Slab:            7064448 kB
>SReclaimable:     143936 kB
>SUnreclaim:      6920512 kB
>
>112084  10550   9%   16.00K   3507       32   1795584K kmalloc-16384
>2497920  48092   1%    0.50K  19515      128   1248960K kmalloc-512 
>6058888  89363   1%    0.19K  17768      341   1137152K kmalloc-192
>114468  13719  11%    4.58K   2082       55    532992K task_struct 
>

This machine has 200 CPUs and 8G memory. There is an oom storm, we are
seeing OOM even in boot process.

Regards,
Wanpeng Li 

>>--
>>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>the body to majordomo@kvack.org.  For more info on Linux MM,
>>see: http://www.linux-mm.org/ .
>>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

>[root@hero05b ~]# cat /sys/kernel/slab/kmalloc-16384/alloc_calls
>      1 .devkmsg_open+0x78/0x130 age=101783 pid=4010 cpus=174 nodes=1
>      1 .pstore_mkfile+0x140/0x440 age=286579 pid=1 cpus=92 nodes=1
>      1 .uart_register_driver+0x48/0x220 age=286591 pid=1 cpus=85 nodes=1
>   1200 .xt_alloc_table_info+0xb0/0x1a0 age=5771/5787/5811 pid=6544-6548 cpus=21,29,193 nodes=1
>    199 .timer_cpu_notify+0xa8/0x324 age=286718/286739/286754 pid=1 cpus=0 nodes=1
>      1 .nvram_init_oops_partition+0x114/0x2a8 age=286703 pid=1 cpus=0 nodes=1
>      1 .sched_init+0x78/0x4d8 age=286769 pid=0 cpus=0 nodes=1
>      1 .tcp_init+0x164/0x3a0 age=286641 pid=1 cpus=85 nodes=1
>[root@hero05b ~]# cat /sys/kernel/slab/kmalloc-16384/free_calls
>   1403 <not-available> age=4295224069 pid=0 cpus=0 nodes=1
>      1 .pidlist_free+0x2c/0x60 age=101818 pid=1 cpus=52 nodes=1
>      1 .unpack_to_rootfs+0x2c0/0x308 age=286610 pid=1 cpus=85 nodes=1
>[root@hero05b ~]#
>[root@hero05b ~]# cat /sys/kernel/slab/kmalloc-512/alloc_calls
>    819 .alloc_workqueue_attrs+0x34/0xa0 age=3516/284970/286802 pid=1-8310 cpus=0,21,85,116,131,165 nodes=1
>     37 .__alloc_workqueue_key+0x68/0x420 age=5707/174337/286802 pid=1-6622 cpus=0,13,17,29,31,61,64,85,116,165 nodes=1
>     14 .add_sysfs_param.isra.3+0x7c/0x220 age=9511/240457/286699 pid=1-5886 cpus=0,16,30-31,114,116 nodes=1
>    600 .build_sched_domains+0x10c/0xdf0 age=271541/271542/271544 pid=1815 cpus=85 nodes=1
>    250 .build_sched_domains+0x144/0xdf0 age=271541/271542/271544 pid=1815 cpus=85 nodes=1
>    252 .build_sched_domains+0x178/0xdf0 age=271541/271542/271544 pid=1815 cpus=85 nodes=1
>    400 .build_sched_domains+0x6dc/0xdf0 age=271540/271540/271543 pid=1815 cpus=85 nodes=1
>  18000 .alloc_fair_sched_group+0xec/0x1e0 age=2579/19587/286617 pid=1-8462 cpus=0-1,5,9,21,26,29,41,61,69,73,76-77,89,92-93,97,101,109,121,125,133,141,145,149,153,161,185 nodes=1
>     99 .cgroup_mkdir+0x7c/0x6e0 age=2587/75021/286606 pid=1 cpus=0-1,52,58,92,110-111,128,130-131,175 nodes=1
>     22 .alloc_desc+0x48/0x100 age=286642/286772/286807 pid=0-1 cpus=0,85 nodes=1
>    400 .rb_allocate_cpu_buffer+0x60/0x2f0 age=286756/286777/286798 pid=1 cpus=0 nodes=1
>      2 .__ring_buffer_alloc+0x54/0x300 age=286798/286798/286798 pid=1 cpus=0 nodes=1
>     14 .init_syscall_trace+0x140/0x190 age=286742/286742/286742 pid=1 cpus=0 nodes=1
>      1 .mempool_create_node+0x88/0x1b0 age=286474 pid=2001 cpus=116 nodes=1
>      2 .mempool_kmalloc+0x1c/0x30 age=286696/286696/286696 pid=1 cpus=0 nodes=1
>      1 .pcpu_mem_zalloc+0x40/0xc0 age=286456 pid=1964 cpus=0 nodes=1
>      1 .__vmalloc_node_range+0xd0/0x300 age=286806 pid=0 cpus=0 nodes=1
>     21 .fsnotify_alloc_group+0x38/0x110 age=5511/53156/286640 pid=1-6840 cpus=1,29,54,57,70,85,128-131,153,158 nodes=1
>    612 .__register_sysctl_table+0xb8/0x700 age=9472/269874/286803 pid=0-5984 cpus=0,16-17,19,30-31,85 nodes=1
>      1 .ipc_alloc+0x20/0x60 age=2905 pid=8437 cpus=1 nodes=1
>     37 .blkcg_activate_policy+0x1b0/0x410 age=102480/275032/286473 pid=1963-3831 cpus=0,2,64,116 nodes=1
>      1 .mpi_alloc_limb_space+0x1c/0x40 age=286621 pid=1 cpus=85 nodes=1
>      1 .__tty_alloc_driver+0xc0/0x1f0 age=286681 pid=1 cpus=85 nodes=1
>      1 .__tty_alloc_driver+0xd8/0x1f0 age=286681 pid=1 cpus=85 nodes=1
>      1 .__tty_alloc_driver+0x180/0x1f0 age=286681 pid=1 cpus=85 nodes=1
>      1 .pty_unix98_install+0x58/0x2f0 age=2584 pid=8458 cpus=198 nodes=1
>      1 .pty_unix98_install+0x70/0x2f0 age=2584 pid=8458 cpus=198 nodes=1
>      2 .vt_do_kdsk_ioctl+0xd8/0x4b0 age=286590/286590/286590 pid=1847 cpus=141 nodes=1
>      2 .con_do_clear_unimap.isra.2+0x138/0x150 age=9568/148123/286679 pid=1-5691 cpus=85,130 nodes=1
>      8 .set_inverse_transl+0xdc/0x100 age=9568/148079/286591 pid=1848-5691 cpus=130,145 nodes=1
>      1 .hvc_alloc+0x6c/0x3a0 age=286629 pid=1 cpus=85 nodes=1
>     17 .bus_register+0x44/0x380 age=286624/286699/286745 pid=1 cpus=0,85 nodes=1
>     36 .__class_register+0x5c/0x2c0 age=4448/278725/286741 pid=1-7859 cpus=0,5,85,114,116,155 nodes=1
>     25 .realloc_buffer+0x48/0xb0 age=262053/262058/262068 pid=1834 cpus=0,2-3,127,150 nodes=1
>      2 .__alloc_skb+0x8c/0x200 age=9594/9594/9594 pid=5655 cpus=137 nodes=1
>      1 .ops_init+0x50/0x1c0 age=101823 pid=3996 cpus=4 nodes=1
>      2 .alloc_netdev_mqs+0x16c/0x380 age=101667/194181/286695 pid=1-4130 cpus=0,76 nodes=1
>     10 .neigh_alloc+0xb0/0x340 age=5679/8716/9500 pid=0-6688 cpus=0,125-126,138,181,183 nodes=1
>    800 .xt_jumpstack_alloc+0xbc/0x1d0 age=5791/5797/5803 pid=6547-6548 cpus=21,29 nodes=1
>      6 .xt_hook_link+0x50/0x190 age=9491/9507/9526 pid=5836-5940 cpus=17-18 nodes=1
>      2 .inetdev_init+0x44/0x180 age=101666/194172/286679 pid=1-4130 cpus=76,85 nodes=1
>      1 .xfrm_sysctl_init+0x4c/0xf0 age=286679 pid=1 cpus=85 nodes=1
>      1 .ip6_route_net_init+0x7c/0x1b0 age=286621 pid=1 cpus=85 nodes=1
>      1 .ip6_route_net_init+0xb8/0x1b0 age=286621 pid=1 cpus=85 nodes=1
>      1 .ip6_route_net_init+0xf0/0x1b0 age=286621 pid=1 cpus=85 nodes=1
>      1 .nl_portid_hash_zalloc+0x24/0x60 age=10016 pid=4074 cpus=121 nodes=1
>    100 .new_cache+0x44/0xb4 age=286704/286723/286740 pid=1 cpus=0 nodes=1
>      2 .dm_table_create+0x4c/0xf0 [dm_mod] age=102480/102480/102481 pid=3831 cpus=64 nodes=1
>     32 .kmem_alloc+0x8c/0x120 [xfs] age=2834/66214/102462 pid=2047-8440 cpus=14,16,30,35,57-59,62,68,71,128,130-131,154 nodes=1
>     10 .rpc_new_client+0xa8/0x580 [sunrpc] age=3518/5208/5701 pid=6609-8310 cpus=1,131,196 nodes=1
>      4 .xprt_alloc+0x174/0x200 [sunrpc] age=3518/4570/5623 pid=6609-8310 cpus=131,196 nodes=1
>      2 .xprt_alloc_slot+0x144/0x240 [sunrpc] age=5657/5660/5664 pid=6610-6616 cpus=1,198 nodes=1
>      3 .__svc_create+0x4c/0x2d0 [sunrpc] age=3516/4244/5698 pid=6609-8310 cpus=131,196 nodes=1
>      1 .svc_prepare_thread+0xdc/0x2b0 [sunrpc] age=3515 pid=8310 cpus=131 nodes=1
>      1 .svc_prepare_thread+0xfc/0x2b0 [sunrpc] age=3515 pid=8310 cpus=131 nodes=1
>      1 .cache_create_net+0x44/0xc0 [sunrpc] age=101825 pid=3996 cpus=30 nodes=1
>      2 .rpc_alloc_iostats+0x20/0x40 [sunrpc] age=3518/3518/3518 pid=8310 cpus=131 nodes=1
>      1 .ibmveth_alloc_buffer_pool+0x28/0x130 [ibmveth] age=9502 pid=5924 cpus=181 nodes=1
>      1 .nf_conntrack_pernet_init+0xa8/0x1a0 [nf_conntrack] age=9511 pid=5886 cpus=16 nodes=1
>      1 .nfs4_get_state_owner+0x294/0x4d0 [nfsv4] age=1444 pid=8502 cpus=6 nodes=1
>      1 .nfs40_init_client+0x38/0xd0 [nfsv4] age=5699 pid=6616 cpus=1 nodes=1
>[root@hero05b ~]# cat /sys/kernel/slab/kmalloc-512/free_calls
>  22508 <not-available> age=4295224106 pid=0 cpus=0 nodes=1
>      3 .apply_workqueue_attrs+0x37c/0x4f0 age=286652/286715/286772 pid=1 cpus=0,85 nodes=1
>     10 .apply_workqueue_attrs+0x38c/0x4f0 age=3548/230076/286827 pid=1-8310 cpus=0,85,116,131 nodes=1
>      3 .krealloc+0xd4/0x130 age=286723/286723/286724 pid=1 cpus=0 nodes=1
>      8 .load_elf_binary+0xa44/0xdf0 age=1476/112397/286618 pid=1845-8502 cpus=0,5,62,65,105,133,137,181 nodes=1
>      1 .crypto_larval_destroy+0x3c/0x60 age=286654 pid=1 cpus=85 nodes=1
>      3 .RSA_verify_signature+0x8c/0x2f0 age=5736/39041/101848 pid=4002-6624 cpus=0,16,166 nodes=1
>      1 .efi_partition+0x134/0x660 age=262086 pid=3620 cpus=2 nodes=1
>     13 .blkg_free+0x20/0x60 age=286471/286471/286471 pid=410 cpus=175 nodes=1
>      1 .mpi_free+0x34/0x80 age=9541 pid=5886 cpus=16 nodes=1
>      2 .vt_do_kdsk_ioctl+0x11c/0x4b0 age=286617/286617/286617 pid=1847 cpus=141 nodes=1
>     88 .skb_free_head+0x64/0x80 age=2616/111166/286720 pid=1-8458 cpus=0-1,3,5,7,29,48-49,56,58,85,92,108,110-111,122,128-129,131,133,181,189,198 nodes=1
>     21 .load_elf_interp.constprop.7+0x4a8/0x50c age=3136/115232/286618 pid=1848-8420 cpus=9,25,53,65,69,105,125,130,133,137,141,145,153,161-162,169,189 nodes=1
>      1 .dm_table_add_target+0x158/0x450 [dm_mod] age=102506 pid=3831 cpus=64 nodes=1
>      4 .sd_revalidate_disk+0x39c/0x1680 [sd_mod] age=262078/262083/262093 pid=6-3618 cpus=0,2,40-41 nodes=1
>      3 .kmem_free+0x44/0x60 [xfs] age=9446/36327/89852 pid=3986-6027 cpus=59,70-71 nodes=1
>      2 .xprt_free+0x84/0xc0 [sunrpc] age=5653/5653/5654 pid=2046-6609 cpus=196 nodes=1
>[root@hero05b ~]#
>[root@hero05b ~]# cat /sys/kernel/slab/kmalloc-192/alloc_calls
>      9 .add_sysfs_param.isra.3+0x7c/0x220 age=101897/266228/286770 pid=1-3996 cpus=0,30 nodes=1
>     73 .groups_alloc+0x40/0x180 age=271/5679/9676 pid=5653-8555 cpus=1-2,26,41,48,53,63,70,97,120,128-129,137,152,154-155,162,169,171,199 nodes=1
>  18000 .alloc_fair_sched_group+0x110/0x1e0 age=2637/19654/286688 pid=1-8462 cpus=0-1,5,9,21,26,29,41,61,69,73,76-77,89,92-93,97,101,109,121,125,133,141,145,149,153,161,185 nodes=1
>      1 .pm_qos_power_open+0xa0/0x100 age=9569 pid=5865 cpus=142 nodes=1
>     44 .find_css_set+0x290/0x440 age=2646/20237/286679 pid=1 cpus=0-1,57-59,92,110-111,131 nodes=1
>     90 .init_syscall_trace+0x140/0x190 age=286813/286813/286813 pid=1 cpus=0 nodes=1
>      1 .__vmalloc_node_range+0xd0/0x300 age=102540 pid=3877 cpus=17 nodes=1
>      1 .SyS_swapon+0x94/0xc40 age=101554 pid=5502 cpus=57 nodes=1
>     22 .alloc_pipe_info+0x30/0x100 age=2643/23789/101909 pid=1-8461 cpus=41,48,53,61,120,128,130-131,138,142,154,157,196 nodes=1
>      1 .mounts_open_common+0x114/0x2f0 age=102140 pid=1 cpus=53 nodes=1
>     13 .SyS_epoll_create1+0x68/0x1e0 age=3509/29245/102174 pid=1-8356 cpus=5-6,29,41,48,53,125,129-130,145,174 nodes=1
>      4 .SyS_timerfd_create+0x5c/0x140 age=498/53539/102173 pid=1-4010 cpus=6,58,111,174 nodes=1
>   3094 .__proc_create+0xc8/0x180 age=4191/284770/286877 pid=0-7859 cpus=0,4,16,30-31,85,115-116,125,144,155,181,196 nodes=1
>     14 .__register_sysctl_table+0xb8/0x700 age=5767/167151/286874 pid=0-6640 cpus=0,16-17,20-21,29,85 nodes=1
>      1 .__register_sysctl_paths+0x17c/0x230 age=286874 pid=0 cpus=0 nodes=1
>     37 .blkg_alloc+0x60/0x1c0 age=102553/275105/286546 pid=1963-3831 cpus=0,2,64,116 nodes=1
>      6 .assoc_array_insert+0x114/0x1b0 age=271/97447/286692 pid=1-8555 cpus=63,85,196,199 nodes=1
>      6 .__tty_alloc_driver+0x7c/0x1f0 age=286698/286708/286752 pid=1 cpus=85 nodes=1
>    834 .device_private_init+0x30/0xa0 age=4508/265517/286816 pid=1-7859 cpus=0,2-3,40-41,51,60,64,76,85,111,115-116,127,130,137,149-150,155-157,196 nodes=1
>     45 .bus_add_driver+0x7c/0x3b0 age=101737/274293/286766 pid=1-4151 cpus=0,5,39,51,76,85,114,116 nodes=1
>     18 .__class_create+0x44/0xc0 age=4510/271078/286812 pid=1-7859 cpus=0,85,155 nodes=1
>     25 .scsi_probe_and_add_lun+0x658/0xd50 age=284333/284335/284339 pid=2044 cpus=0,2 nodes=1
>      1 .sock_kmalloc+0x60/0xd0 age=9642 pid=5691 cpus=125 nodes=1
>      1 .ops_init+0x50/0x1c0 age=5773 pid=6622 cpus=29 nodes=1
>      4 .neigh_parms_alloc+0x90/0x210 age=101738/194229/286750 pid=1-4130 cpus=76,85 nodes=1
>      5 .fib_default_rule_add+0x3c/0xb0 age=286692/286726/286750 pid=1 cpus=85 nodes=1
>      4 .fib_rules_register+0x24/0x1b0 age=286692/286720/286750 pid=1 cpus=85 nodes=1
>    800 .xt_jumpstack_alloc+0xbc/0x1d0 age=5895/5900/5907 pid=6543-6544 cpus=185,193 nodes=1
>      2 .xt_hook_link+0x50/0x190 age=9565/9576/9588 pid=5852-5931 cpus=17,22 nodes=1
>      3 .ip_mc_inc_group+0x94/0x300 age=9293/101847/286679 pid=1-5924 cpus=92,181,183 nodes=1
>      7 .fib_create_info+0x478/0x10f0 age=9278/88543/286680 pid=1-6119 cpus=45,92,105,181 nodes=1
>      1 .addrconf_init_net+0x38/0x180 age=286692 pid=1 cpus=85 nodes=1
>      1 .addrconf_init_net+0x54/0x180 age=286692 pid=1 cpus=85 nodes=1
>      6 .ipv6_dev_mc_inc+0xe0/0x470 age=5749/132029/286692 pid=1-6655 cpus=27,76,85,181 nodes=1
>      1 .sched_init_numa+0x378/0x4ac age=286827 pid=1 cpus=0 nodes=1
>     13 .kmem_alloc+0x8c/0x120 [xfs] age=4718/94558/102535 pid=3875-7759 cpus=13-14,30,61-62 nodes=1
>      1 .unx_create_cred+0x50/0x1c0 [sunrpc] age=5749 pid=6609 cpus=196 nodes=1
>      4 .generic_create_cred+0x44/0x190 [sunrpc] age=3578/5204/5767 pid=6609-8310 cpus=1,131,196,198 nodes=1
>      1 .udp_init_net+0x74/0xb0 [nf_conntrack] age=9576 pid=5894 cpus=17 nodes=1
>    171 .__nf_ct_ext_add_length+0x22c/0x260 [nf_conntrack] age=0/2351/9411 pid=0-8545 cpus=0-1,25,35,41,49,75,125-126,139,141,145,149-151,183,196-199 nodes=1
>      1 .nf_conntrack_ecache_pernet_init+0x44/0xf0 [nf_conntrack] age=9578 pid=5886 cpus=16 nodes=1
>[root@hero05b ~]# cat /sys/kernel/slab/kmalloc-192/free_calls
>  23123 <not-available> age=4295224340 pid=0 cpus=0 nodes=1
>     10 .mod_verify_sig+0x35c/0x540 age=4712/54016/283623 pid=2005-7860 cpus=5,16-18,21,30,51,119 nodes=1
>     31 .rcu_nocb_kthread+0x248/0x390 age=68/2191/9554 pid=410-606 cpus=0-1,196-198 nodes=1
>      8 .krealloc+0xd4/0x130 age=4713/170777/286967 pid=1-7859 cpus=0,4,16,76,137,155 nodes=1
>      6 .kzfree+0x40/0x60 age=286897/286897/286897 pid=1821-1826 cpus=5 nodes=1
>     33 .free_pipe_info+0xa8/0xd0 age=207/23588/262275 pid=3790-8660 cpus=1,3,8,10,25,27,30-31,37-39,43,45-46,54,57,73,79,86-87,93,97,121,131,137,150,173-174,190,195-196 nodes=1
>      2 .seq_release+0x28/0x50 age=9854/136063/262273 pid=3800-5730 cpus=117,185 nodes=1
>    115 .bio_put+0xe8/0xf0 age=109229/266317/286738 pid=0-3645 cpus=0,65,125,129,133 nodes=1
>      7 .ep_free+0x104/0x130 age=101936/138391/262322 pid=3633-4223 cpus=18,54,78,96-97,102,120 nodes=1
>      7 .SyS_name_to_handle_at+0x190/0x260 age=9797/62620/286874 pid=1-5701 cpus=6,92,160 nodes=1
>      3 .pde_put+0x74/0xa0 age=4394/131212/286875 pid=1-7805 cpus=4,92,125 nodes=1
>      1 .cryptomgr_test+0x38/0x80 age=286897 pid=1828 cpus=5 nodes=1
>      1 .x509_free_certificate+0x5c/0x90 age=286889 pid=1 cpus=85 nodes=1
>      1 .x509_free_certificate+0x74/0x90 age=286889 pid=1 cpus=85 nodes=1
>      1 .blkg_free+0x44/0x60 age=286712 pid=410 cpus=175 nodes=1
>      1 .assoc_array_destroy_subtree+0x170/0x240 age=1645 pid=2240 cpus=199 nodes=1
>      1 .driver_release+0x34/0x70 age=286895 pid=1 cpus=85 nodes=1
>      9 .___sys_sendmsg+0x1b0/0x380 age=2853/5881/9902 pid=1-5691 cpus=1,58,111,138 nodes=1
>      1 .xt_free_table_info+0x1cc/0x270 age=8340 pid=6301 cpus=9 nodes=1
>      2 .kmem_free+0x44/0x60 [xfs] age=5888/54122/102357 pid=1-6712 cpus=53,155 nodes=1
>      1 .nfs_d_automount+0x134/0x250 [nfs] age=5824 pid=6616 cpus=196 nodes=1
>      2 .nfs4_put_open_state+0xc8/0x110 [nfsv4] age=1680/1686/1692 pid=8517 cpus=122,197 nodes=1
>[root@hero05b ~]#

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
