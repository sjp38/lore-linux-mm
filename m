Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 283F26B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 23:15:57 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so213733644pab.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 20:15:56 -0800 (PST)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id y2si22164649par.178.2015.11.30.20.15.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Nov 2015 20:15:55 -0800 (PST)
Subject: Re: [PATCH] bugfix oom kill init lead panic
References: <1448880869-20506-1-git-send-email-chenjie6@huawei.com>
 <20151129190802.dc66cf35.akpm@linux-foundation.org>
 <565BC23F.6070302@huawei.com>
 <alpine.DEB.2.10.1511301407080.10460@chino.kir.corp.google.com>
From: "Chenjie (K)" <chenjie6@huawei.com>
Message-ID: <565D1EED.6070306@huawei.com>
Date: Tue, 1 Dec 2015 12:15:41 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1511301407080.10460@chino.kir.corp.google.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com, lizefan@huawei.com, stable@vger.kernel.org


Thank you reply, we run a test case.

A new log:

Out of memory: Kill process 8520 (sshd) score 11 or sacrifice child
Killed process 8520 (sshd) total-vm:5812kB, anon-rss:404kB, file-rss:2132kB
[RSM][SIG]Kernel:dd(pid:8612|tid:8612) send SIG[9] to 
sshd(pid:8520|tid:8520).
CPU: 0 PID: 8612 Comm: dd Tainted: G           O 3.10.53-HULK2 #1
[<c0018e68>] (unwind_backtrace+0x0/0x11c) from [<c0014548>] 
(show_stack+0x10/0x14)
[<c0014548>] (show_stack+0x10/0x14) from [<bf173640>] 
(send_signal_entry+0xd4/0x144 [rsm])
[<bf173640>] (send_signal_entry+0xd4/0x144 [rsm]) from [<c0037028>] 
(__send_signal+0x2bc/0x310)
[<c0037028>] (__send_signal+0x2bc/0x310) from [<c003710c>] 
(send_signal+0x90/0x94)
[<c003710c>] (send_signal+0x90/0x94) from [<c0037b88>] 
(do_send_sig_info+0x3c/0x64)
[<c0037b88>] (do_send_sig_info+0x3c/0x64) from [<c00c7750>] 
(oom_kill_process+0x384/0x3d8)
[<c00c7750>] (oom_kill_process+0x384/0x3d8) from [<c00c7bf4>] 
(out_of_memory+0x26c/0x2b0)
[<c00c7bf4>] (out_of_memory+0x26c/0x2b0) from [<c00cad8c>] 
(__alloc_pages_nodemask+0x558/0x6f8)
[<c00cad8c>] (__alloc_pages_nodemask+0x558/0x6f8) from [<c00d647c>] 
(shmem_getpage_gfp+0x1bc/0x5e0)
[<c00d647c>] (shmem_getpage_gfp+0x1bc/0x5e0) from [<c00c4a24>] 
(generic_file_buffered_write+0xdc/0x23c)
[<c00c4a24>] (generic_file_buffered_write+0xdc/0x23c) from [<c00c5b7c>] 
(__generic_file_aio_write+0x33c/0x3a8)
[<c00c5b7c>] (__generic_file_aio_write+0x33c/0x3a8) from [<c00c5c3c>] 
(generic_file_aio_write+0x54/0xb0)
[<c00c5c3c>] (generic_file_aio_write+0x54/0xb0) from [<c00ff5ec>] 
(do_sync_write+0x74/0x98)
[<c00ff5ec>] (do_sync_write+0x74/0x98) from [<c00fff80>] 
(vfs_write+0xcc/0x1a8)
[<c00fff80>] (vfs_write+0xcc/0x1a8) from [<c0100374>] (SyS_write+0x38/0x64)
[<c0100374>] (SyS_write+0x38/0x64) from [<c0010960>] 
(ret_fast_syscall+0x0/0x60)
[RSM][SIG]sshd(pid:8520|tid:8520) deliver SIG[9].
[RSM][SIG]tr(pid:9088|tid:9088) deliver SIG[9].
dd invoked oom-killer: gfp_mask=0x200da, order=0, oom_score_adj=0
dd cpuset=/ mems_allowed=0
CPU: 0 PID: 8612 Comm: dd Tainted: G           O 3.10.53-HULK2 #1
[<c0018e68>] (unwind_backtrace+0x0/0x11c) from [<c0014548>] 
(show_stack+0x10/0x14)
[<c0014548>] (show_stack+0x10/0x14) from [<c02e22b4>] 
(dump_header.isra.12+0x90/0x1c0)
[<c02e22b4>] (dump_header.isra.12+0x90/0x1c0) from [<c00c7428>] 
(oom_kill_process+0x5c/0x3d8)
[<c00c7428>] (oom_kill_process+0x5c/0x3d8) from [<c00c7bf4>] 
(out_of_memory+0x26c/0x2b0)
[<c00c7bf4>] (out_of_memory+0x26c/0x2b0) from [<c00cad8c>] 
(__alloc_pages_nodemask+0x558/0x6f8)
[<c00cad8c>] (__alloc_pages_nodemask+0x558/0x6f8) from [<c00d647c>] 
(shmem_getpage_gfp+0x1bc/0x5e0)
[<c00d647c>] (shmem_getpage_gfp+0x1bc/0x5e0) from [<c00c4a24>] 
(generic_file_buffered_write+0xdc/0x23c)
[<c00c4a24>] (generic_file_buffered_write+0xdc/0x23c) from [<c00c5b7c>] 
(__generic_file_aio_write+0x33c/0x3a8)
[<c00c5b7c>] (__generic_file_aio_write+0x33c/0x3a8) from [<c00c5c3c>] 
(generic_file_aio_write+0x54/0xb0)
[<c00c5c3c>] (generic_file_aio_write+0x54/0xb0) from [<c00ff5ec>] 
(do_sync_write+0x74/0x98)
[<c00ff5ec>] (do_sync_write+0x74/0x98) from [<c00fff80>] 
(vfs_write+0xcc/0x1a8)
[<c00fff80>] (vfs_write+0xcc/0x1a8) from [<c0100374>] (SyS_write+0x38/0x64)
[<c0100374>] (SyS_write+0x38/0x64) from [<c0010960>] 
(ret_fast_syscall+0x0/0x60)
Mem-info:
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  15
CPU    1: hi:   90, btch:  15 usd:  19
active_anon:1505 inactive_anon:35705 isolated_anon:0
  active_file:0 inactive_file:1 isolated_file:0
  unevictable:10743 dirty:0 writeback:0 unstable:0
  free:452 slab_reclaimable:1377 slab_unreclaimable:2922
  mapped:833 shmem:36300 pagetables:161 bounce:0
  free_cma:0
Normal free:1808kB min:1812kB low:2264kB high:2716kB active_anon:6020kB 
inactive_anon:142820kB active_file:0kB inactive_file:4kB 
unevictable:42972kB isolated(anon):0kB isolated(file):0kB 
present:307200kB managed:205416kB mlocked:0kB dirty:0kB writeback:0kB 
mapped:3332kB shmem:145200kB slab_reclaimable:5508kB 
slab_unreclaimable:11688kB kernel_stack:672kB pagetables:644kB 
unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:23 
all_unreclaimable? yes
lowmem_reserve[]: 0 0 0
Normal: 24*4kB (UEMR) 21*8kB (UER) 5*16kB (UEM) 2*32kB (MR) 2*64kB (M) 
2*128kB (M) 2*256kB (M) 1*512kB (M) 0*1024kB 0*2048kB 0*4096kB = 1816kB
47049 total pagecache pages
76800 pages of RAM
679 free pages
22676 reserved pages
2830 slab pages
532708 pages shared
0 pages swap cached
[ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[ 1021]     0  1021      493      139       5        0             0 RATC
[ 1023]     0  1023      493      123       5        0         -1000 RATC
[ 1112]     0  1112     1302      511       4        0         -1000 sshd
[ 1130]     0  1130      824      278       5        0             0 crond
[ 1505]     0  1505      490      130       5        0             0 
take_cpu_rate
[ 1506]     0  1506      490       32       5        0             0 
take_cpu_rate
[ 1508]     0  1508      490       32       5        0             0 
take_cpu_rate
[ 2315]     0  2315      731      165       5        0             0 getty
[11839]     0 11839      731      191       5        0             0 
debug_runtest.s
[11848]     0 11848      731      165       5        0             0 
istress.sh
[11852]     0 11852      730      156       5        0             0 
spacectl.sh
[12109]     0 12109      730      156       5        0             0 
bsd_stress.sh
[ 8552]     0  8552      462      130       4        0             0 
lockf.test
[ 8553]     0  8553      462       45       4        0             0 
lockf.test
[ 8554]     0  8554      462       86       4        0             0 
lockf.test
[ 8555]     0  8555      462       86       4        0             0 
lockf.test
[ 8557]     0  8557      462       86       4        0             0 
lockf.test
[10732]     0 10732      462       16       4        0             0 
lockf.test
[10042]     0 10042      730      132       5        0             0 bash
[10043]     0 10043      730      159       5        0             0 
runtest.sh
[10068]     0 10068      730       92       5        0             0 
runtest.sh
[10069]     0 10069      730      159       5        0             0 
rel_mem_inodeca
[10072]     0 10072      697       99       4        0             0 sleep
[ 8403]     0  8403      697       98       4        0             0 cp
[ 8569]     0  8569      730      159       5        0             0 
runtest.sh
[ 8606]     0  8606      730       92       5        0             0 
runtest.sh
[ 8607]     0  8607      730      155       5        0             0 
rel_mem_filecac
[ 8610]     0  8610      697       99       4        0             0 sleep
[ 8611]     0  8611      732       99       5        0             0 tr
[ 8612]     0  8612      730       99       5        0             0 dd
[ 9073]     0  9073     1454      593       6        0             0 sshd
[ 9083]   502  9083     1302      283       5        0             0 sshd
[ 9086]     0  9086     1463      542       7        0             0 
syslog-ng
[ 9090]     0  9090      730       19       4        0             0 
rel_mem_inodeca

more info about it
*****************Start oom extend info.*****************
Vmallocinfo Start >>>>>>>>>>>>>>>>>>>>
0xbf000000-0xbf006000   24576 module_alloc_update_bounds+0xc/0x5c 
pages=5 vmalloc
0xbf00a000-0xbf00e000   16384 module_alloc_update_bounds+0xc/0x5c 
pages=3 vmalloc
0xbf011000-0xbf013000    8192 module_alloc_update_bounds+0xc/0x5c 
pages=1 vmalloc
0xbf015000-0xbf017000    8192 module_alloc_update_bounds+0xc/0x5c 
pages=1 vmalloc
0xbf019000-0xbf01b000    8192 module_alloc_update_bounds+0xc/0x5c 
pages=1 vmalloc
0xbf01d000-0xbf021000   16384 module_alloc_update_bounds+0xc/0x5c 
pages=3 vmalloc
0xbf024000-0xbf032000   57344 module_alloc_update_bounds+0xc/0x5c 
pages=13 vmalloc
0xbf039000-0xbf03c000   12288 module_alloc_update_bounds+0xc/0x5c 
pages=2 vmalloc
0xbf03f000-0xbf042000   12288 module_alloc_update_bounds+0xc/0x5c 
pages=2 vmalloc
0xbf044000-0xbf046000    8192 module_alloc_update_bounds+0xc/0x5c 
pages=1 vmalloc
0xbf048000-0xbf04a000    8192 module_alloc_update_bounds+0xc/0x5c 
pages=1 vmalloc
0xbf04c000-0xbf04e000    8192 module_alloc_update_bounds+0xc/0x5c 
pages=1 vmalloc
0xbf050000-0xbf054000   16384 module_alloc_update_bounds+0xc/0x5c 
pages=3 vmalloc
0xbf056000-0xbf059000   12288 module_alloc_update_bounds+0xc/0x5c 
pages=2 vmalloc
0xbf05b000-0xbf069000   57344 module_alloc_update_bounds+0xc/0x5c 
pages=13 vmalloc
0xbf06d000-0xbf08e000  135168 module_alloc_update_bounds+0xc/0x5c 
pages=32 vmalloc
0xbf096000-0xbf0ce000  229376 module_alloc_update_bounds+0xc/0x5c 
pages=55 vmalloc
0xbf0e8000-0xbf0ea000    8192 module_alloc_update_bounds+0xc/0x5c 
pages=1 vmalloc
0xbf0ec000-0xbf0fe000   73728 module_alloc_update_bounds+0xc/0x5c 
pages=17 vmalloc
0xbf105000-0xbf12a000  151552 module_alloc_update_bounds+0xc/0x5c 
pages=36 vmalloc
0xbf13d000-0xbf145000   32768 module_alloc_update_bounds+0xc/0x5c 
pages=7 vmalloc
0xbf149000-0xbf168000  126976 module_alloc_update_bounds+0xc/0x5c 
pages=30 vmalloc
0xbf173000-0xbf179000   24576 module_alloc_update_bounds+0xc/0x5c 
pages=5 vmalloc
0xbf17c000-0xbf180000   16384 module_alloc_update_bounds+0xc/0x5c 
pages=3 vmalloc
0xbf182000-0xbf186000   16384 module_alloc_update_bounds+0xc/0x5c 
pages=3 vmalloc
0xbf192000-0xbf1a5000   77824 module_alloc_update_bounds+0xc/0x5c 
pages=18 vmalloc
0xbf1ab000-0xbf1ad000    8192 module_alloc_update_bounds+0xc/0x5c 
pages=1 vmalloc
0xd3000000-0xd3021000  135168 ekbox_reinit+0x3c/0xcc phys=9fa00000 ioremap
0xd3022000-0xd3024000    8192 of_iomap+0x30/0x3c phys=1a001000 ioremap
0xd3024000-0xd3027000   12288 of_iomap+0x30/0x3c phys=1a000000 ioremap
0xd3028000-0xd302a000    8192 of_iomap+0x30/0x3c phys=20000000 ioremap
0xd302a000-0xd302c000    8192 of_iomap+0x30/0x3c phys=20011000 ioremap
0xd302c000-0xd302f000   12288 of_iomap+0x30/0x3c phys=1a000000 ioremap
0xd3030000-0xd3032000    8192 of_iomap+0x30/0x3c phys=20013000 ioremap
0xd3032000-0xd3034000    8192 bsp_init_led+0x320/0x5e8 phys=f000b000 ioremap
0xd3034000-0xd3036000    8192 bsp_init_led+0x394/0x5e8 phys=f000b000 ioremap
0xd303a000-0xd307b000  266240 atomic_pool_init+0x0/0x11c phys=8d500000 user
0xd3080000-0xd3082000    8192 l2cache_init+0xb8/0x3b8 phys=16800000 ioremap
0xd3916000-0xd3959000  274432 0xbf08e26c pages=66 vmalloc
0xd3959000-0xd3965000   49152 0xbf08e280 pages=11 vmalloc
0xd3965000-0xd396a000   20480 0xbf08e2e0 pages=4 vmalloc
0xd396a000-0xd396d000   12288 0xbf08e2ec pages=2 vmalloc
0xd3a3f000-0xd3a42000   12288 pcpu_extend_area_map+0x18/0xa0 pages=2 vmalloc
0xd3ad8000-0xd3ada000    8192 0xbf1a54ac phys=9fffe000 ioremap
0xd3adc000-0xd3ade000    8192 0xbf1a517c phys=30000000 ioremap
0xd3ade000-0xd3ae0000    8192 0xbf1a51b0 phys=20000000 ioremap
0xd3af2000-0xd3af4000    8192 0xbf1a517c phys=30001000 ioremap
0xd3af4000-0xd3af6000    8192 0xbf1a51b0 phys=20000000 ioremap
0xd3af6000-0xd3af8000    8192 0xbf1a517c phys=30002000 ioremap
0xd3af8000-0xd3afa000    8192 0xbf1a51b0 phys=20000000 ioremap
0xd3afa000-0xd3afc000    8192 0xbf1a517c phys=30003000 ioremap
0xd3afc000-0xd3afe000    8192 0xbf1a51b0 phys=20000000 ioremap
0xd3c00000-0xd3e01000 2101248 kbox_proc_mem_write+0x104/0x1cc 
phys=9f800000 ioremap
0xd4000000-0xd8001000 67112960 devm_ioremap+0x38/0x70 phys=40000000 ioremap
0xfe001000-0xfe002000    4096 iotable_init+0x0/0xb4 phys=20001000 ioremap
0xfe200000-0xfe201000    4096 iotable_init+0x0/0xb4 phys=1a000000 ioremap
0xfee00000-0xff000000 2097152 pci_reserve_io+0x0/0x30 ioremap
Vmallocinfo End <<<<<<<<<<<<<<<<<<<<

[SLUB]Slabinfo Start >>>>>>>>>>>>>>>>>>>>
# name            <active_objs> <num_objs> <objsize> <objperslab> 
<pagesperslab> : slabdata <active_slabs> <num_slabs>
nfs_direct_cache       0      0    120   34    1 : slabdata      0      0
nfs_commit_data       18     18    448   18    2 : slabdata      1      1
nfs_read_data          0      0    576   14    2 : slabdata      0      0
nfs_inode_cache        0      0    816   20    4 : slabdata      0      0
rpc_inode_cache        0      0    512   16    2 : slabdata      0      0
jffs2_refblock       432    432    248   16    1 : slabdata     27     27
jffs2_i              274    546    552   14    2 : slabdata     39     39
bsg_cmd                0      0    288   14    1 : slabdata      0      0
mqueue_inode_cache     23     23    704   23    4 : slabdata      1      1
squashfs_inode_cache      0      0    576   14    2 : slabdata      0      0
ext2_inode_cache       0      0    640   12    2 : slabdata      0      0
pid_namespace        102    102     80   51    1 : slabdata      2      2
user_namespace         0      0    224   18    1 : slabdata      0      0
posix_timers_cache      0      0    160   25    1 : slabdata      0      0
UDP-Lite               0      0    640   12    2 : slabdata      0      0
UDP                   24     24    640   12    2 : slabdata      2      2
tw_sock_TCP           64     64    128   32    1 : slabdata      2      2
TCP                   24     24   1344   12    4 : slabdata      2      2
eventpoll_pwq        204    204     40  102    1 : slabdata      2      2
sgpool-128            12     12   2560   12    8 : slabdata      1      1
sgpool-64             12     12   1280   12    4 : slabdata      1      1
sgpool-16             12     12    320   12    1 : slabdata      1      1
blkdev_queue          50     50   1272   25    8 : slabdata      2      2
blkdev_requests       54     54    216   18    1 : slabdata      3      3
fsnotify_event_holder   7696   8960     16  256    1 : slabdata     35 
    35
fsnotify_event       112    112     72   56    1 : slabdata      2      2
biovec-256            10     10   3072   10    8 : slabdata      1      1
biovec-128             0      0   1536   21    8 : slabdata      0      0
biovec-64              0      0    768   21    4 : slabdata      0      0
sock_inode_cache      64     64    512   16    2 : slabdata      4      4
skbuff_fclone_cache     63     63    384   21    2 : slabdata      3      3
file_lock_cache     1904   1904    120   34    1 : slabdata     56     56
net_namespace          0      0   2240   14    8 : slabdata      0      0
shmem_inode_cache  10184  10890    528   15    2 : slabdata    726    726
proc_inode_cache     391    496    504   16    2 : slabdata     31     31
sigqueue             169    308    144   28    1 : slabdata     11     11
bdev_cache            23     23    704   23    4 : slabdata      1      1
inode_cache         2920   3315    472   17    2 : slabdata    195    195
dentry             13777  20412    144   28    1 : slabdata    729    729
buffer_head            0      0     64   64    1 : slabdata      0      0
vm_area_struct      1702   1748     88   46    1 : slabdata     38     38
signal_cache         171    240    640   12    2 : slabdata     20     20
sighand_cache        110    144   1344   12    4 : slabdata     12     12
task_struct          134    182   2304   14    8 : slabdata     13     13
anon_vma_chain      2364   3328     32  128    1 : slabdata     26     26
anon_vma            2409   2409     56   73    1 : slabdata     33     33
debug_objects_cache   3594   8500     24  170    1 : slabdata     50     50
radix_tree_node     1259   1352    304   13    1 : slabdata    104    104
idr_layer_cache      105    105   1080   15    4 : slabdata      7      7
kmalloc-8192          20     20   8192    4    8 : slabdata      5      5
kmalloc-4096          48     48   4096    8    8 : slabdata      6      6
kmalloc-2048          96     96   2048   16    8 : slabdata      6      6
kmalloc-1024         330    400   1024   16    4 : slabdata     25     25
kmalloc-512          911    976    512   16    2 : slabdata     61     61
kmalloc-256          211    240    256   16    1 : slabdata     15     15
kmalloc-192         1228   1344    192   21    1 : slabdata     64     64
kmalloc-128         2324   2624    128   32    1 : slabdata     82     82
kmalloc-64         23749  24192     64   64    1 : slabdata    378    378
kmem_cache_node      128    128     64   64    1 : slabdata      2      2
kmem_cache            96     96    128   32    1 : slabdata      3      3
Slabinfo End <<<<<<<<<<<<<<<<<<<<


Filesystem            1K-blocks    Used   Available Use(%)   Mounted on
tmpfs                   524288        4   524284        0%   /tmp
none                     10240    10240        0      100%   /var
tmpfs                   108248       16   108232        0%   /dev
tmpfs                   108248        0   108248        0%   /dev/shm
tmpfs                   173192   134960    38232       77%   /tmp
*****smap info of all task:*****
   smaps info of task-sshd[9073], rss:2372 kB:
   smaps info of task-syslog-ng[9086], rss:2168 kB:
   smaps info of task-sshd[1112], rss:2044 kB:
   smaps info of task-sshd[9083], rss:1132 kB:
   smaps info of task-crond[1130], rss:1112 kB:
********    mem info     *****	Total:                 216496 kB
	Total free:              1808 kB
	User space:            191816 kB
	Mlock:                      0 kB
	Kernel space:           22872 kB
	Bootmem reserved:       90704 kB
	kernel_image_info:
	    Kernel code:   0x80008000-0x8043369f
	    Kernel data:   0x80496000-0x8056559b
	module info:
	    physmap 3kB         Live 0xbf1ab000 (O)
			refrence count: 1
                                -
	    Drv_Gmac_K 71kB         Live 0xbf192000 (O)
			refrence count: 0
                                -
	    rtos_snapshot 10kB         Live 0xbf182000 (O)
			refrence count: 0
                                -
	    rtos_kbox_panic 10kB         Live 0xbf17c000 (O)
			refrence count: 0
                                -
	    rsm 16kB         Live 0xbf173000 (O)
			refrence count: 0
                                -
	    nfsv4 119kB         Live 0xbf149000
			refrence count: 0
                                -
	    nfsv3 24kB         Live 0xbf13d000
			refrence count: 0
                                -
	    nfs 141kB         Live 0xbf105000
			refrence count: 2
			nfsv4,
			nfsv3,
	    lockd 64kB         Live 0xbf0ec000
			refrence count: 2
			nfsv3,
			nfs,
	    nfs_acl 2kB         Live 0xbf0e8000
			refrence count: 1
			nfsv3,
	    sunrpc 216kB         Live 0xbf096000
			refrence count: 5
			nfsv4,
			nfsv3,
			nfs,
			lockd,
			nfs_acl,
	    jffs2 125kB         Live 0xbf06d000
			refrence count: 1
                                -
	    cfi_cmdset_0002 51kB         Live 0xbf05b000
			refrence count: 1
                                -
	    cfi_probe 5kB         Live 0xbf056000
			refrence count: 0
                                -
	    cfi_util 11kB         Live 0xbf050000
			refrence count: 2
			cfi_cmdset_0002,
			cfi_probe,
	    gen_probe 2kB         Live 0xbf04c000
			refrence count: 1
			cfi_probe,
	    cmdlinepart 2kB         Live 0xbf048000
			refrence count: 0
                                -
	    chipreg 2kB         Live 0xbf044000
			refrence count: 2
			physmap,
			cfi_probe,
	    mtdblock 4kB         Live 0xbf03f000
			refrence count: 0
                                -
	    mtd_blkdevs 7kB         Live 0xbf039000
			refrence count: 1
			mtdblock,
	    mtd 48kB         Live 0xbf024000
			refrence count: 17
			physmap,
			jffs2,
			cfi_cmdset_0002,
			cmdlinepart,
			mtdblock,
			mtd_blkdevs,
	    uio 8kB         Live 0xbf01d000
			refrence count: 0
                                -
	    xt_tcpudp 2kB         Live 0xbf019000
			refrence count: 0
                                -
	    ipt_REJECT 2kB         Live 0xbf015000
			refrence count: 0
                                -
	    iptable_filter 1kB         Live 0xbf011000
			refrence count: 0
                                -
	    ip_tables 11kB         Live 0xbf00a000
			refrence count: 1
			iptable_filter,
	    x_tables 16kB         Live 0xbf000000
			refrence count: 4
			xt_tcpudp,
			ipt_REJECT,
			iptable_filter,
			ip_tables,
******     pagecache_info:     ******
   /rel_mem_filecache_tc11/0 : nrpages = 23260.
   /volatile/log/auth.log : nrpages = 1947.
   /usr/bin/gdb : nrpages = 845.
   /lib/libcrypto.so.1.0.0 : nrpages = 418.
   /usr/lib/libgio-2.0.so.0.3600.4 : nrpages = 391.
   /lib/libc-2.18.so : nrpages = 370.
   /usr/lib/libperl.so.5.14.3 : nrpages = 348.
   /usr/lib/libglib-2.0.so.0.3600.4 : nrpages = 314.
   /usr/lib/libstdc++.so.6.0.17 : nrpages = 277.
   /fs_stress_t/fs_stress_t/testcase/bin/fsback/unit : nrpages = 256.
   /fs_stress_t/fs_stress_t_src/testcase/fsback/unit : nrpages = 256.
   /usr/bin/makedumpfile : nrpages = 238.
   /usr/bin/perf : nrpages = 228.
   /usr/sbin/sshd : nrpages = 226.
   /usr/bin/ssh : nrpages = 202.
   /usr/lib/libbfd-2.23.2.so : nrpages = 195.
   /volatile/log/syslog : nrpages = 192.
   /volatile/log/kern.log : nrpages = 186.
   /lib/libm-2.18.so : nrpages = 173.
   /volatile/log/error : nrpages = 162.
*****************End oom extend info.*****************




On 2015/12/1 6:08, David Rientjes wrote:
> On Mon, 30 Nov 2015, Chenjie (K) wrote:
>
>> My kernel version is 3.10 ,but the 4.3 is the same
>> and the newest code is
>>
>> 	for_each_process(p) {
>> 		if (!process_shares_mm(p, mm))
>> 			continue;
>> 		if (same_thread_group(p, victim))
>> 			continue;
>> 		if (unlikely(p->flags & PF_KTHREAD))
>> 			continue;
>> 		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
>> 			continue;
>>
>> so this not add the i 1/4 ?is_global_init also.
>>
>> when we vfork (CLONE_VM) a process,the copy_mm
>> 	if (clone_flags & CLONE_VM) {
>> 		atomic_inc(&oldmm->mm_users);
>> 		mm = oldmm;
>> 		goto good_mm;
>> 	}
>> use the parent mm.
>>
>
> I think it might be a legitimate fix, but if the oom killer is killing pid
> 9134 in your log then I assume the next call to the oom killer will panic
> the system anyway unless there is actually a process using less memory
> that can be killed.  Would you mind enabling vm.oom_dump_tasks (it should
> default to enabled) and post the entire oom killer log?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
