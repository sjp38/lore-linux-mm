Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C33016B0038
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 07:14:15 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so54129158wms.7
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 04:14:15 -0800 (PST)
Received: from tschil.ethgen.ch (tschil.ethgen.ch. [5.9.7.51])
        by mx.google.com with ESMTPS id pp1si49701020wjc.75.2016.12.27.04.14.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 04:14:13 -0800 (PST)
Date: Tue, 27 Dec 2016 13:14:06 +0100
From: Klaus Ethgen <Klaus+lkml@ethgen.de>
Subject: Re: Bug 4.9 and memorymanagement
Message-ID: <20161227121406.rutpqd5lwyt5dbdi@ikki.ethgen.ch>
References: <20161226110053.GA16042@dhcp22.suse.cz>
 <66baf7dd-c5e3-e11c-092f-3a642c306e63@I-love.SAKURA.ne.jp>
 <20161227114821.j3dl3r7segov6tb3@ikki.ethgen.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; x-action=pgp-signed
In-Reply-To: <20161227114821.j3dl3r7segov6tb3@ikki.ethgen.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

I was just to fast mentioning that my new 4.9 compile did well. Just
after I wrote the mail, I got the same issue again. Now being back to
4.7.

OOM:
   [34629.315415] Unable to lock GPU to purge memory.
   [34629.315542] wicd invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), nodemask=0, order=1, oom_score_adj=0
   [34629.315547] wicd cpuset=/ mems_allowed=0
   [34629.315557] CPU: 1 PID: 2525 Comm: wicd Tainted: G     U     O    4.9.0 #1
   [34629.315560] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.13 ) 04/30/2008
   [34629.315563]  f2cb5ea4 c12b32b0 f2cb5ea4 f0ac8840 c113c861 f2cb5e10 00000206 c12b845f
   [34629.315571]  f3baa100 f2cb5dac ea28cbb3 f0ac8840 f0ac8c6c c159b37f f2cb5ea4 c10e8843
   [34629.315579]  00000000 d298b180 00000000 0013cfe4 c10e84eb 00000284 00000000 00000062
   [34629.315586] Call Trace:
   [34629.315600]  [<c12b32b0>] ? dump_stack+0x44/0x64
   [34629.315607]  [<c113c861>] ? dump_header+0x5d/0x1b7
   [34629.315611]  [<c12b845f>] ? ___ratelimit+0x8f/0xf0
   [34629.315616]  [<c10e8843>] ? oom_kill_process+0x203/0x3d0
   [34629.315620]  [<c10e84eb>] ? oom_badness.part.12+0xeb/0x160
   [34629.315624]  [<c10e8cce>] ? out_of_memory+0xde/0x290
   [34629.315628]  [<c10ec9ec>] ? __alloc_pages_nodemask+0xc3c/0xc50
   [34629.315633]  [<c1044846>] ? copy_process.part.54+0xe6/0x1490
   [34629.315638]  [<c10c84fe>] ? __audit_syscall_entry+0xae/0x110
   [34629.315642]  [<c10011b3>] ? syscall_trace_enter+0x183/0x200
   [34629.315645]  [<c1045d96>] ? _do_fork+0xd6/0x310
   [34629.315649]  [<c10c8736>] ? __audit_syscall_exit+0x1d6/0x260
   [34629.315653]  [<c10014e9>] ? do_fast_syscall_32+0x79/0x130
   [34629.315657]  [<c14c21e2>] ? sysenter_past_esp+0x47/0x75
   [34629.315660] Mem-Info:
   [34629.315667] active_anon:41216 inactive_anon:122089 isolated_anon:0
   [34629.315667]  active_file:345542 inactive_file:145465 isolated_file:1
   [34629.315667]  unevictable:7274 dirty:41 writeback:0 unstable:0
   [34629.315667]  slab_reclaimable:53222 slab_unreclaimable:11663
   [34629.315667]  mapped:43891 shmem:14724 pagetables:797 bounce:0
   [34629.315667]  free:41833 free_pcp:184 free_cma:0
   [34629.315678] Node 0 active_anon:164864kB inactive_anon:488356kB active_file:1382168kB inactive_file:581860kB unevictable:29096kB isolated(anon):0kB isolated(file):4kB mapped:175564kB dirty:164kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 58896kB writeback_tmp:0kB unstable:0kB pages_scanned:9691812 all_unreclaimable? yes
   [34629.315685] DMA free:4084kB min:788kB low:984kB high:1180kB active_anon:204kB inactive_anon:400kB active_file:2632kB inactive_file:0kB unevictable:0kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclaimable:8128kB slab_unreclaimable:428kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   lowmem_reserve[]: 0 833 3008 3008
   [34629.315698] Normal free:42396kB min:42416kB low:53020kB high:63624kB active_anon:3820kB inactive_anon:39704kB active_file:505188kB inactive_file:540kB unevictable:0kB writepending:164kB present:892920kB managed:854344kB mlocked:0kB slab_reclaimable:204760kB slab_unreclaimable:46224kB kernel_stack:2776kB pagetables:32kB bounce:0kB free_pcp:728kB local_pcp:4kB free_cma:0kB
   lowmem_reserve[]: 0 0 17397 17397
   [34629.315710] HighMem free:120852kB min:512kB low:28164kB high:55816kB active_anon:160840kB inactive_anon:448252kB active_file:874348kB inactive_file:581224kB unevictable:29096kB writepending:0kB present:2226888kB managed:2226888kB mlocked:29096kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:3156kB bounce:0kB free_pcp:8kB local_pcp:8kB free_cma:0kB
   lowmem_reserve[]: 0 0 0 0
   [34629.315718] DMA: 61*4kB (UM) 60*8kB (ME) 26*16kB (UME) 28*32kB (ME) 18*64kB (UME) 3*128kB (ME) 2*256kB (UM) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4084kB
   Normal: 2261*4kB (UME) 1667*8kB (UME) 755*16kB (UME) 222*32kB (UME) 13*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 42396kB
   HighMem: 81*4kB (U) 6*8kB (UM) 40*16kB (UM) 691*32kB (UM) 419*64kB (UM) 78*128kB (UM) 102*256kB (UM) 10*512kB (UM) 7*1024kB (UM) 5*2048kB (UM) 3*4096kB (UM) = 120852kB
   509332 total pagecache pages
   [34629.315778] 1424 pages in swap cache
   [34629.315781] Swap cache stats: add 31179, delete 29755, find 254185/259247
   [34629.315783] Free swap  = 2074532kB
   [34629.315785] Total swap = 2096476kB
   [34629.315787] 783948 pages RAM
   [34629.315789] 556722 pages HighMem/MovableOnly
   [34629.315791] 9663 pages reserved
   [34629.315793] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
   [34629.315799] [  216]     0   216     2927      798       5       0        2         -1000 udevd
   [34629.315806] [ 1640]     0  1640     1233       45       5       0        0             0 acpi_fakekeyd
   [34629.315811] [ 1659]     0  1659     3233      404       5       0        0         -1000 auditd
   [34629.315815] [ 1759]     0  1759     7688      328       8       0        0             0 lxcfs
   [34629.315819] [ 1780]     0  1780     5413       76       6       0        0             0 lvmetad
   [34629.315822] [ 1803]     0  1803     7910      165       7       0        0             0 rsyslogd
   [34629.315826] [ 1865]     0  1865      595      448       3       0        0             0 acpid
   [34629.315830] [ 1913]     0  1913      581      379       4       0        0             0 battery-stats-c
   [34629.315834] [ 1935]   103  1935     1108      602       5       0        0             0 dbus-daemon
   [34629.315838] [ 1983]     8  1983     1058      454       4       0        0             0 nullmailer-send
   [34629.315842] [ 2001]     0  2001     1451      553       5       0        0             0 bluetoothd
   [34629.315846] [ 2008]     0  2008     2003      989       6       0        0             0 haveged
   [34629.315850] [ 2017]     0  2017     7111      423       7       0        0             0 pcscd
   [34629.315853] [ 2076]     0  2076      558       18       4       0        0             0 thinkfan
   [34629.315857] [ 2077]     0  2077      559      182       4       0        0             0 startpar
   [34629.315862] [ 2102]     0  2102     2129      391       5       0        0         -1000 sshd
   [34629.315865] [ 2109]     0  2109     1460      337       5       0        0             0 smartd
   [34629.315869] [ 2147]   124  2147      824      416       4       0        0             0 ulogd
   [34629.315873] [ 2282]   110  2282     5261     2286       9       0        0             0 unbound
   [34629.315877] [ 2393]   121  2393      957      470       4       0      119             0 privoxy
   [34629.315881] [ 2394]     0  2394      601        0       4       0       21             0 uuidd
   [34629.315885] [ 2416]     0  2416     1406      518       5       0       25             0 cron
   [34629.315889] [ 2459]     0  2459     1511        2       5       0       75             0 wdm
   [34629.315892] [ 2462]     0  2462     1511      412       5       0       77             0 wdm
   [34629.315897] [ 2469]     0  2469    32107     9124      28       0     2625             0 Xorg
   [34629.315901] [ 2525]     0  2525     8382     3056      10       0      597             0 wicd
   [34629.315905] [ 2556]     0  2556     4975     1579       8       0      869             0 wicd-monitor
   [34629.315908] [ 2581]     0  2581      553      122       4       0       16             0 mingetty
   [34629.315912] [ 2588]     0  2588     1698      588       5       0      145             0 wdm
   [34629.315916] [ 2604] 10230  2604    13645     1993      11       0        0             0 fvwm2
   [34629.315920] [ 2662] 10230  2662     1136        0       5       0       65             0 dbus-launch
   [34629.315924] [ 2663] 10230  2663     1075      595       5       0       21             0 dbus-daemon
   [34629.315928] [ 2680] 10230  2680     8460      584       8       0       40             0 gpg-agent
   [34629.315932] [ 2684] 10230  2684     3957      478       6       0       61             0 tpb
   [34629.315936] [ 2696] 10230  2696     2098     1097       6       0       32             0 xscreensaver
   [34629.315940] [ 2698] 10230  2698     2937      404       6       0       72             0 redshift
   [34629.315944] [ 2710] 10230  2710     1346      731       5       0        0             0 autocutsel
   [34629.315948] [ 2717] 10230  2717    10943     3617      13       0        0             0 gkrellm
   [34629.315952] [ 2718] 10230  2718    54515    18285      43       0        0             0 psi-plus
   [34629.315955] [ 2719] 10230  2719    11929     7489      15       0        0             0 wicd-client
   [34629.315959] [ 2741] 10230  2741     1047      255       5       0        0             0 FvwmCommandS
   [34629.315964] [ 2742] 10230  2742     1528      347       5       0        0             0 FvwmEvent
   [34629.315968] [ 2743] 10230  2743    12182     1079       9       0        0             0 FvwmAnimate
   [34629.315971] [ 2744] 10230  2744    12808      996      11       0        0             0 FvwmButtons
   [34629.315975] [ 2745] 10230  2745    13344     1330      11       0        0             0 FvwmProxy
   [34629.315979] [ 2746] 10230  2746     1507      316       4       0        0             0 FvwmAuto
   [34629.315983] [ 2747] 10230  2747    12803      974      11       0        0             0 FvwmPager
   [34629.315987] [ 2748] 10230  2748      581      143       4       0        0             0 sh
   [34629.315991] [ 2749] 10230  2749     1063      407       4       0        0             0 stalonetray
   [34629.315994] [ 2908] 10230  2908     1073      479       5       0        0             0 xsnow
   [34629.315999] [ 2935] 10230  2935   295381   127866     253       0        1             0 firefox.real
   [34629.316030] [ 5794] 10230  5794     2816     1470       6       0        0             0 xterm
   [34629.316034] [ 5797] 10230  5797     2308     1629       6       0        0             0 zsh
   [34629.316038] [ 5962] 10230  5962     3406     2006       6       0        0             0 xterm
   [34629.316041] [ 5963] 10230  5963     2495      645       6       0        0             0 ssh
   [34629.316045] [ 5970]     0  5970     2899      492       6       0        1             0 sshd
   [34629.316050] [ 5974] 10230  5974     8535      531       8       0        0             0 scdaemon
   [34629.316053] [ 6008] 10230  6008     2529      291       6       0        0             0 ssh
   [34629.316057] [ 6011]     0  6011     2074     1333       6       0       15             0 zsh
   [34629.316063] [ 7225] 10230  7225     2813     1423       7       0        0             0 xterm
   [34629.316067] [ 7228] 10230  7228     2089     1383       5       0        0             0 zsh
   [34629.316070] [24346] 10230 24346     2027     1052       5       0        0             0 xfconfd
   [34629.316075] [28935] 10230 28935     2825     1655       6       0        0             0 xterm
   [34629.316079] [28938] 10230 28938     1903     1236       6       0        0             0 zsh
   [34629.316083] [ 3534]     0  3534     7724     7231      11       0        0         -1000 ulatencyd
   [34629.316088] [13919]     0 13919     2190      785       5       0        0             0 wpa_supplicant
   [34629.316092] [13965]     0 13965     2026      181       4       0        0             0 dhclient
   [34629.316095] [14016] 65534 14016     2289     1431       7       0        0             0 openvpn
   [34629.316099] [14024]   120 14024     7407     6469      11       0        0             0 tor
   [34629.316104] [18617] 10230 18617    14715     8499      18       0        0             0 vim
   [34629.316108] [19852]     0 19852      557      134       4       0        0             0 sleep
   [34629.316112] [20042] 10230 20042    40711    11341      31       0        0             0 zathura
   [34629.316115] Out of memory: Kill process 2935 (firefox.real) score 98 or sacrifice child
   [34629.316216] Killed process 2935 (firefox.real) total-vm:1181524kB, anon-rss:429748kB, file-rss:72444kB, shmem-rss:9272kB
   [34633.828297] oom_reaper: reaped process 2935 (firefox.real), now anon-rss:0kB, file-rss:32kB, shmem-rss:9248kB

   [34701.040055] Xorg invoked oom-killer: gfp_mask=0x24200d4(GFP_USER|GFP_DMA32|__GFP_RECLAIMABLE), nodemask=0, order=0, oom_score_adj=0
   [34701.040064] Xorg cpuset=/ mems_allowed=0
   [34701.040074] CPU: 1 PID: 2469 Comm: Xorg Tainted: G     U     O    4.9.0 #1
   [34701.040077] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.13 ) 04/30/2008
   [34701.040081]  f32efa6c c12b32b0 f32efa6c f16b3180 c113c861 00001f8f 00200206 c12b845f
   [34701.040089]  f32efa54 f59eab80 c10349d5 f16b3180 f16b35ac c159b37f f32efa6c c10e8843
   [34701.040096]  00000000 ee7f98c0 00000000 0013cfe4 c10e84eb 0000043d 00000000 0000000e
   [34701.040104] Call Trace:
   [34701.040115]  [<c12b32b0>] ? dump_stack+0x44/0x64
   [34701.040122]  [<c113c861>] ? dump_header+0x5d/0x1b7
   [34701.040126]  [<c12b845f>] ? ___ratelimit+0x8f/0xf0
   [34701.040132]  [<c10349d5>] ? smp_trace_apic_timer_interrupt+0x55/0x80
   [34701.040137]  [<c10e8843>] ? oom_kill_process+0x203/0x3d0
   [34701.040140]  [<c10e84eb>] ? oom_badness.part.12+0xeb/0x160
   [34701.040143]  [<c10e8cce>] ? out_of_memory+0xde/0x290
   [34701.040148]  [<c10ec9ec>] ? __alloc_pages_nodemask+0xc3c/0xc50
   [34701.040153]  [<c10fb557>] ? shmem_alloc_and_acct_page+0x137/0x210
   [34701.040158]  [<c10e4965>] ? find_get_entry+0xd5/0x110
   [34701.040161]  [<c10fbe85>] ? shmem_getpage_gfp+0x165/0xbb0
   [34701.040167]  [<c14be22d>] ? schedule+0x2d/0x80
   [34701.040174]  [<c14bf3df>] ? wait_for_completion+0xbf/0xe0
   [34701.040178]  [<c1067cf0>] ? wake_up_q+0x60/0x60
   [34701.040181]  [<c10fc912>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [34701.040228]  [<f8ae79b1>] ? i915_gem_object_get_pages_gtt+0x1e1/0x3d0 [i915]
   [34701.040251]  [<f8ae2441>] ? ggtt_bind_vma+0x41/0x70 [i915]
   [34701.040275]  [<f8ae81f5>] ? i915_gem_object_get_pages+0x35/0xb0 [i915]
   [34701.040300]  [<f8aea197>] ? __i915_vma_do_pin+0x117/0x6b0 [i915]
   [34701.040323]  [<f8adb5ae>] ? i915_gem_execbuffer_reserve_vma.isra.36+0x15e/0x1f0 [i915]
   [34701.040347]  [<f8adba4b>] ? i915_gem_execbuffer_reserve.isra.37+0x40b/0x440 [i915]
   [34701.040370]  [<f8add3f1>] ? i915_gem_do_execbuffer.isra.40+0x5d1/0x11d0 [i915]
   [34701.040390]  [<f81b71e6>] ? drm_vma_node_allow+0x86/0xb0 [drm]
   [34701.040395]  [<c112b82f>] ? __kmalloc+0xdf/0x160
   [34701.040418]  [<f8ade40e>] ? i915_gem_execbuffer2+0x7e/0x220 [i915]
   [34701.040443]  [<f8af10ff>] ? i915_gem_set_tiling+0x12f/0x480 [i915]
   [34701.040466]  [<f8ade390>] ? i915_gem_execbuffer+0x3a0/0x3a0 [i915]
   [34701.040476]  [<f81a55c3>] ? drm_ioctl+0x1b3/0x3e0 [drm]
   [34701.040500]  [<f8ade390>] ? i915_gem_execbuffer+0x3a0/0x3a0 [i915]
   [34701.040505]  [<c1140562>] ? do_readv_writev+0x132/0x400
   [34701.040509]  [<c14123b0>] ? kernel_sendmsg+0x50/0x50
   [34701.040519]  [<f81a5410>] ? drm_getunique+0x40/0x40 [drm]
   [34701.040523]  [<c115259f>] ? do_vfs_ioctl+0x8f/0x770
   [34701.040529]  [<c10c84fe>] ? __audit_syscall_entry+0xae/0x110
   [34701.040532]  [<c10011b3>] ? syscall_trace_enter+0x183/0x200
   [34701.040536]  [<c10c80d1>] ? audit_filter_inodes+0xc1/0x100
   [34701.040540]  [<c10c7bd5>] ? audit_filter_syscall+0xa5/0xd0
   [34701.040544]  [<c115c601>] ? __fget+0x61/0xb0
   [34701.040548]  [<c1152cae>] ? SyS_ioctl+0x2e/0x50
   [34701.040551]  [<c10014e9>] ? do_fast_syscall_32+0x79/0x130
   [34701.040555]  [<c14c21e2>] ? sysenter_past_esp+0x47/0x75
   [34701.040558] Mem-Info:
   [34701.040565] active_anon:24871 inactive_anon:31713 isolated_anon:0
   [34701.040565]  active_file:345258 inactive_file:145071 isolated_file:4
   [34701.040565]  unevictable:7256 dirty:140 writeback:0 unstable:0
   [34701.040565]  slab_reclaimable:52226 slab_unreclaimable:11653
   [34701.040565]  mapped:28020 shmem:13879 pagetables:547 bounce:0
   [34701.040565]  free:150608 free_pcp:158 free_cma:0
   [34701.040576] Node 0 active_anon:99484kB inactive_anon:126852kB active_file:1381032kB inactive_file:580284kB unevictable:29024kB isolated(anon):0kB isolated(file):16kB mapped:112080kB dirty:560kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 55516kB writeback_tmp:0kB unstable:0kB pages_scanned:21492992 all_unreclaimable? yes
   [34701.040584] DMA free:4112kB min:788kB low:984kB high:1180kB active_anon:204kB inactive_anon:404kB active_file:2632kB inactive_file:0kB unevictable:0kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclaimable:8128kB slab_unreclaimable:428kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   lowmem_reserve[]: 0 833 3008 3008
   [34701.040597] Normal free:42352kB min:42416kB low:53020kB high:63624kB active_anon:3412kB inactive_anon:43628kB active_file:506844kB inactive_file:156kB unevictable:0kB writepending:236kB present:892920kB managed:854344kB mlocked:0kB slab_reclaimable:200776kB slab_unreclaimable:46184kB kernel_stack:2424kB pagetables:28kB bounce:0kB free_pcp:376kB local_pcp:232kB free_cma:0kB
   lowmem_reserve[]: 0 0 17397 17397
   [34701.040609] HighMem free:555968kB min:512kB low:28164kB high:55816kB active_anon:95868kB inactive_anon:82820kB active_file:871556kB inactive_file:580128kB unevictable:29024kB writepending:324kB present:2226888kB managed:2226888kB mlocked:29024kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:2160kB bounce:0kB free_pcp:256kB local_pcp:180kB free_cma:0kB
   lowmem_reserve[]: 0 0 0 0
   [34701.040617] DMA: 62*4kB (UME) 59*8kB (ME) 26*16kB (UME) 29*32kB (UME) 18*64kB (UME) 3*128kB (ME) 2*256kB (UM) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4112kB
   Normal: 2356*4kB (ME) 1742*8kB (UME) 707*16kB (UME) 212*32kB (UME) 14*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 42352kB
   HighMem: 11250*4kB (UM) 8793*8kB (UM) 4821*16kB (UM) 2769*32kB (UM) 1309*64kB (UM) 421*128kB (UM) 236*256kB (UM) 58*512kB (UM) 16*1024kB (UM) 7*2048kB (UM) 4*4096kB (UM) = 555968kB
   507833 total pagecache pages
   [34701.040677] 1423 pages in swap cache
   [34701.040679] Swap cache stats: add 31179, delete 29756, find 254737/259799
   [34701.040682] Free swap  = 2074540kB
   [34701.040684] Total swap = 2096476kB
   [34701.040686] 783948 pages RAM
   [34701.040688] 556722 pages HighMem/MovableOnly
   [34701.040690] 9663 pages reserved
   [34701.040692] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
   [34701.040701] [  216]     0   216     2927      798       5       0        2         -1000 udevd
   [34701.040711] [ 1640]     0  1640     1233       45       5       0        0             0 acpi_fakekeyd
   [34701.040716] [ 1659]     0  1659     3233      404       5       0        0         -1000 auditd
   [34701.040721] [ 1759]     0  1759     7688      328       8       0        0             0 lxcfs
   [34701.040725] [ 1780]     0  1780     5413       76       6       0        0             0 lvmetad
   [34701.040729] [ 1803]     0  1803     7910      165       7       0        0             0 rsyslogd
   [34701.040734] [ 1865]     0  1865      595      448       3       0        0             0 acpid
   [34701.040738] [ 1913]     0  1913      581      379       4       0        0             0 battery-stats-c
   [34701.040742] [ 1935]   103  1935     1108      602       5       0        0             0 dbus-daemon
   [34701.040746] [ 1983]     8  1983     1058      454       4       0        0             0 nullmailer-send
   [34701.040750] [ 2001]     0  2001     1451      553       5       0        0             0 bluetoothd
   [34701.040754] [ 2008]     0  2008     2003      989       6       0        0             0 haveged
   [34701.040759] [ 2017]     0  2017     7111      423       7       0        0             0 pcscd
   [34701.040763] [ 2076]     0  2076      558       18       4       0        0             0 thinkfan
   [34701.040767] [ 2077]     0  2077      559      182       4       0        0             0 startpar
   [34701.040772] [ 2102]     0  2102     2129      391       5       0        0         -1000 sshd
   [34701.040776] [ 2109]     0  2109     1460      337       5       0        0             0 smartd
   [34701.040780] [ 2147]   124  2147      824      416       4       0        0             0 ulogd
   [34701.040784] [ 2282]   110  2282     5261     2286       9       0        0             0 unbound
   [34701.040788] [ 2393]   121  2393      957      470       4       0      119             0 privoxy
   [34701.040792] [ 2394]     0  2394      601        0       4       0       21             0 uuidd
   [34701.040797] [ 2416]     0  2416     1406      518       5       0       25             0 cron
   [34701.040801] [ 2459]     0  2459     1511        2       5       0       75             0 wdm
   [34701.040805] [ 2462]     0  2462     1511      412       5       0       77             0 wdm
   [34701.040810] [ 2469]     0  2469    29966     7317      28       0     2625             0 Xorg
   [34701.040814] [ 2525]     0  2525     8382     3056      10       0      597             0 wicd
   [34701.040818] [ 2556]     0  2556     4975     1579       8       0      869             0 wicd-monitor
   [34701.040823] [ 2581]     0  2581      553      122       4       0       16             0 mingetty
   [34701.040827] [ 2588]     0  2588     1698      588       5       0      145             0 wdm
   [34701.040831] [ 2604] 10230  2604    13645     1993      11       0        0             0 fvwm2
   [34701.040835] [ 2662] 10230  2662     1136        0       5       0       65             0 dbus-launch
   [34701.040839] [ 2663] 10230  2663     1075      595       5       0       21             0 dbus-daemon
   [34701.040844] [ 2680] 10230  2680     8460      584       8       0       40             0 gpg-agent
   [34701.040848] [ 2684] 10230  2684     3957      478       6       0       61             0 tpb
   [34701.040852] [ 2696] 10230  2696     2098     1097       6       0       32             0 xscreensaver
   [34701.040856] [ 2698] 10230  2698     2937      404       6       0       72             0 redshift
   [34701.040860] [ 2710] 10230  2710     1346      731       5       0        0             0 autocutsel
   [34701.040864] [ 2717] 10230  2717    10943     3617      13       0        0             0 gkrellm
   [34701.040868] [ 2718] 10230  2718    54515    18285      43       0        0             0 psi-plus
   [34701.040872] [ 2719] 10230  2719    11929     7489      15       0        0             0 wicd-client
   [34701.040876] [ 2741] 10230  2741     1047      255       5       0        0             0 FvwmCommandS
   [34701.040881] [ 2742] 10230  2742     1528      347       5       0        0             0 FvwmEvent
   [34701.040885] [ 2743] 10230  2743    12182     1079       9       0        0             0 FvwmAnimate
   [34701.040889] [ 2744] 10230  2744    12808      996      11       0        0             0 FvwmButtons
   [34701.040894] [ 2745] 10230  2745    13344     1330      11       0        0             0 FvwmProxy
   [34701.040898] [ 2746] 10230  2746     1507      316       4       0        0             0 FvwmAuto
   [34701.040902] [ 2747] 10230  2747    12803      974      11       0        0             0 FvwmPager
   [34701.040907] [ 2748] 10230  2748      581      143       4       0        0             0 sh
   [34701.040911] [ 2749] 10230  2749     1063      407       4       0        0             0 stalonetray
   [34701.040915] [ 2908] 10230  2908     1073      479       5       0        0             0 xsnow
   [34701.040919] [ 5794] 10230  5794     2816     1470       6       0        0             0 xterm
   [34701.040923] [ 5797] 10230  5797     2308     1629       6       0        0             0 zsh
   [34701.040927] [ 5962] 10230  5962     3406     2006       6       0        0             0 xterm
   [34701.040931] [ 5963] 10230  5963     2495      645       6       0        0             0 ssh
   [34701.040935] [ 5970]     0  5970     2899      492       6       0        1             0 sshd
   [34701.040940] [ 5974] 10230  5974     8535      531       8       0        0             0 scdaemon
   [34701.040944] [ 6008] 10230  6008     2529      291       6       0        0             0 ssh
   [34701.040948] [ 6011]     0  6011     2074     1333       6       0       15             0 zsh
   [34701.040955] [ 7225] 10230  7225     2813     1423       7       0        0             0 xterm
   [34701.040959] [ 7228] 10230  7228     2089     1383       5       0        0             0 zsh
   [34701.040963] [24346] 10230 24346     2027     1052       5       0        0             0 xfconfd
   [34701.040968] [28935] 10230 28935     2825     1655       6       0        0             0 xterm
   [34701.040972] [28938] 10230 28938     1903     1236       6       0        0             0 zsh
   [34701.040977] [ 3534]     0  3534     7706     7230      11       0        0         -1000 ulatencyd
   [34701.040982] [13919]     0 13919     2190      785       5       0        0             0 wpa_supplicant
   [34701.040987] [13965]     0 13965     2026      181       4       0        0             0 dhclient
   [34701.040991] [14016] 65534 14016     2289     1431       7       0        0             0 openvpn
   [34701.040995] [14024]   120 14024     7407     6469      11       0        0             0 tor
   [34701.041000] [18617] 10230 18617    14715     8499      18       0        0             0 vim
   [34701.096211] [20110]     0 20110      557      135       4       0        0             0 sleep
   [34701.096222] [20305] 10230 20305    42766    13755      34       0        0             0 zathura
   [34701.096226] Out of memory: Kill process 2718 (psi-plus) score 14 or sacrifice child
   [34701.096253] Killed process 2718 (psi-plus) total-vm:218060kB, anon-rss:34692kB, file-rss:36680kB, shmem-rss:1768kB
   [34701.605857] oom_reaper: reaped process 2718 (psi-plus), now anon-rss:0kB, file-rss:0kB, shmem-rss:1768kB
   [34703.917075] Purging GPU memory, 4333 pages freed, 7594 pages still pinned.

Regards
   Klaus
- -- 
Klaus Ethgen                                       http://www.ethgen.ch/
pub  4096R/4E20AF1C 2011-05-16            Klaus Ethgen <Klaus@Ethgen.ch>
Fingerprint: 85D4 CA42 952C 949B 1753  62B3 79D0 B06F 4E20 AF1C
-----BEGIN PGP SIGNATURE-----
Comment: Charset: ISO-8859-1

iQGzBAEBCgAdFiEEMWF28vh4/UMJJLQEpnwKsYAZ9qwFAlhiWwgACgkQpnwKsYAZ
9qxdxwv/cPVmQDUKReWCI5/5DXixxVt+9H+6oLyvUcHn1hPyCYHzNsRKI13j4yHv
3Q05i4i8bq/HbhoNd3kYx3IISlDWfMEeaO3m/fDroAsHlgHEY2Mc+PdfKdiJtZQh
oMIpIVRiFV7hwsXAZeUh2tCAJeMimchA6z6yvSMzs5cz1FRUR0AmGwqVjAYIRIvV
PWF36aIroITl0CnKqLfq6u7I6ZGBpZntF6XQxj3App2mhF+SB06GmRnBAxQkMGJn
iM5oe9FSU8i/NWRDjAxJCEBWLwdTf1oL5udx/0ZQ3Qu2SNvlB0yQl9LbI9+925qm
OgF/LxBko1yl+n+cezqnKKxm9hCwv3tKKu4Dx1vFQBZmtI8fddmLPFAXXqKP5cye
MLMhLnnR/SpqSoIKkkDeMv1I3oGhJa9VaQ/aE7tDPmm2oMebrZ0fMBhMBHcGU4ch
JPH1qO54tx7TAexmDFDGhTNxHt6NGEs3QXaDHb7MfoW66vUUjjKPGgnDmhdL+iTJ
wnkvxODi
=K+I5
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
