Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 10D0B6B0073
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 05:20:17 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id y19so5794203wgg.7
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 02:20:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pk3si60878129wjc.61.2014.12.08.02.20.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 02:20:14 -0800 (PST)
Date: Mon, 8 Dec 2014 11:20:13 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Question] page allocation failure
Message-ID: <20141208102013.GA23999@dhcp22.suse.cz>
References: <BLUPR03MB373C60E05B4073C76EBEA62F5640@BLUPR03MB373.namprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLUPR03MB373C60E05B4073C76EBEA62F5640@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Cc: "rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>

Starting a new thread is not very much helpful. Just for reference the
original thread was started here:
http://marc.info/?l=linux-mm&m=141777497709236
and CMA (or its configuration) as a potential culprit pointed at
http://marc.info/?l=linux-mm&m=141778416412151

I have suggested to contact CMA people. git log on mm/cma.c suggests:
Joonsoo Kim, Marek Szyprowski and Laurent Pinchart maybe there are
others. I am not familiar with CMA much myself.

So please reopen the original thread and add the relevant people into
the CC list. You can remove cgroups mailing list as this doesn't seem to
be related to the cgroups.

On Mon 08-12-14 03:25:57, fugang.duan@freescale.com wrote:
> Hi, all expert,
> 
> I run one case on i.MX6q-sabresd board, and found page allocation failure, but the kernel dump show there have free memory, I don't know why does allocate page failed.
> Any points or comment are appreciated.
> 
> The case:
> 
> -          Board: imx6q sabresd board: 1G ddr memory
> 
> -          Kernel version: 3.10.53, with CMA enabled
> 
> -          After kernel up,  nfs mount one streaming server, and then aplay the streaming in loop.
> 
> -          After 1 hours test,  kernel dump page allocation failure,  but networking and system is active.
> 
> -          i.MX6q networking driver:  drivers/net/ethernet/freescale/fec_main.c
> 
> The dump log:
> 
> root@imx6qdlsolo:/mnt/src/RVDec/1080#
> x800_24fps_1940kbps_a_44.1khz_96.5Kbps_2_Transformers2_h1080p.rmvb -rv9_ra6_1920
> playbin is employed!
> Generate VideoSink overlaysink
> set color key:00010203
> ====== OVERLAYSINK: 4.0.2 build on Nov 23 2014 22:24:34. ======
> fsl_player_init(): Successfully initialize!
> fsl_player_set_media_location(): filename=RMVB_1080p_30fps_30Mbps_mp3.rmvb
> [Stopped  (List Repeated)][Vol=01][00:00:00/00:00:00]
> ====== AIUR: 4.0.2 build on Nov 23 2014 22:24:26. ======
>         Core: RMPARSER_03.00.25  build on Nov 14 2014 06:32:48
> file: /usr/lib/imx-mm/parser/lib_rm_parser_arm11_elinux.so.3.0
> ------------------------
>     Track 00 [video_0] Enabled
>         Duration: 0:01:41.736000000
>         Language:
>     Mime:
>         video/x-pn-realvideo, width=(int)1920, height=(int)1080, framerate=(fraction)30/1, codec_data=(buffer)000000225649444f5256343007800438000c00000000001e00000148102040008000
> ------------------------
> [INFO]  Product Info: i.MX6Q/D/S
> ====== VPUDEC: 4.0.2 build on Nov 23 2014 22:24:42. ======
>        wrapper: 1.0.56 (VPUWRAPPER_ARM_LINUX Build on Nov 23 2014 22:19:27)
>         vpulib: 5.4.27
>         firmware: 3.1.1.46062
> ------------------------
>     Track 01 [audio_0] Enabled
>         Duration: 0:01:42.166000000
>         Language:
>     Mime:
>         audio/x-pn-realaudio, channels=(int)2, rate=(int)44100, frame_bit=(int)2240, codec_data=(buffer)01000003080000250000000000080005
> ------------------------
> [INFO]  bitstreamMode 1, chromaInterleave 1, mapType 0, tiled2LinearEnable 0
> 
> ====== BEEP: 4.0.2 build on Nov 23 2014 22:24:30. ======
>         Core: Real Audio decoder Wrapper  build on Nov 18 2014 10:41:40
> filmxc_v4l2_output v4l2_out.39: Bypass IC.
> e: /usr/lib/imx-mm/audio-codec/wrmxc_v4l2_output v4l2_out.39: Bypass IC.
> ap/lib_realad_wrap_arm11_elinux.so.1
> CODEC: REALAUDIOD_ARM_01.01.00_ARM11  build on Sep  4 2014 14:37:18.
> fsl_player_play()
> 
> FSL_PLAYER_01.00_LINUX build on Nov 23 2014 22:24:47
>         [h]display the operation Help
>         [p]Play
>         [s]Stop
>         [e]Seek
>         [a]Pause when playing, play when paused
>         [v]Volume
>         [m]Switch to mute or not
>         [>]Play next file
>         [<]Play previous file
>         [r]Switch to repeated mode or not
>         [f]Set full screen or not
>         [z]resize the width and height
>         [t]Rotate
>         [c]Setting play rate
>         [i]Display the metadata
>         [x]eXit
> [Playing  (List Repeated)][Vol=01][00:01:41/00:01:42]EOS Found!
> FSL_PLAYER_UI_MSG_EOS
> Total showed frames (3049), display master blited (3049), playing for (0:01:42.130724000), fps (29.854).
> fsl_player_stop()
> RV9_1920x1080_23.976fps_6059kbps_RV6_44.1khz_96.5kbps_2ch.rmvb
> fsl_player_stop()
> fsl_player_set_media_location(): filename=RV9_1920x1080_23.976fps_6059kbps_RV6_44.1khz_96.5kbps_2ch.rmvb
> 
> ====== AIUR: 4.0.2 build on Nov 23 2014 22:24:26. ======
>         Core: RMPARSER_03.00.25  build on Nov 14 2014 06:32:48
> file: /usr/lib/imx-mm/parser/lib_rm_parser_arm11_elinux.so.3.0
> ------------------------
>     Track 00 [video_0] Enabled
>         Duration: 0:04:00.783000000
>         Language:
>     Mime:
>         video/x-pn-realvideo, width=(int)1920, height=(int)1080, framerate=(fraction)785645/32768, codec_data=(buffer)000000225649444f5256343007800438000c000000000017f9da0148102040008000
> ------------------------
> [INFO]  Product Info: i.MX6Q/D/S
> ====== VPUDEC: 4.0.2 build on Nov 23 2014 22:24:42. ======
>         wrapper: 1.0.56 (VPUWRAPPER_ARM_LINUX Build on Nov 23 2014 22:19:27)
>         vpulib: 5.4.27
>         firmware: 3.1.1.46062
> ------------------------
>     Track 01 [audio_0] Enabled
>         Duration: 0:04:01.486000000
>         Language:
>     Mime:
>         audio/x-pn-realaudio, channels=(int)2, rate=(int)44100, frame_bit=(int)2240, codec_data=(buffer)01000003080000250000000000080005
> ------------------------
> [INFO]  bitstreamMode 1, chromaInterleave 1, mapType 0, tiled2LinearEnable 0
> 
> ====== BEEP: 4.0.2 build on Nov 23 2014 22:24:30. ======
>         Core:mxc_v4l2_output v4l2_out.39: Bypass IC.
> Real Audio decoder Wrapper  builmxc_v4l2_output v4l2_out.39: Bypass IC.
> d on Nov 18 2014 10:41:40
> file: /usr/lib/imx-mm/audio-codec/wrap/lib_realad_wrap_arm11_elinux.so.1
> CODEC: REALAUDIOD_ARM_01.01.00_ARM11  build on Sep  4 2014 14:37:18.
> fsl_player_play()
> [Playing  (List Repeated)][Vol=01][00:04:00/00:04:01]EOS Found!
> FSL_PLAYER_UI_MSG_EOS
> Total showed frames (5774), display master blited (5774), playing for (0:04:01.448752000), fps (23.914).
> [Playing  (List Repeated)][Vol=01][00:00:00/00:00:00]fsl_player_stop()
> rv10_ra6_1920x1080_24fps_5495kbps_a_44.1khz_44.1Kbps_2_avatar-fte1_h1080p.rmvb
> fsl_player_stop()
> fsl_player_set_media_location(): filename=rv10_ra6_1920x1080_24fps_5495kbps_a_44.1khz_44.1Kbps_2_avatar-fte1_h1080p.rmvb
> 
> ====== AIUR: 4.0.2 build on Nov 23 2014 22:24:26. ======
>         Core: RMPARSER_03.00.25  build on Nov 14 2014 06:32:48
> file: /usr/lib/imx-mm/parser/lib_rm_parser_arm11_elinux.so.3.0
> ------------------------
>     Track 00 [video_0] Enabled
>         Duration: 0:04:06.749000000
>         Language:
>     Mime:
>         video/x-pn-realvideo, width=(int)1920, height=(int)1080, framerate=(fraction)1571291/65536, codec_data=(buffer)000000225649444f5256343007800438000c000000000017f9db0108102040008000
> ------------------------
> [INFO]  Product Info: i.MX6Q/D/S
> ====== VPUDEC: 4.0.2 build on Nov 23 2014 22:24:42. ======
>         wrapper: 1.0.56 (VPUWRAPPER_ARM_LINUX Build on Nov 23 2014 22:19:27)
>         vpulib: 5.4.27
>         firmware: 3.1.1.46062
> ------------------------
>     Track 01 [audio_0] Enabled
>         Duration: 0:04:07.059000000
>         Language:
>     Mime:
>         audio/x-pn-realaudio, channels=(int)2, rate=(int)44100, frame_bit=(int)1024, codec_data=(buffer)01000003080000250000000000020004
> ------------------------
> [INFO]  bitstreamMode 1, chromaInterleave 1, mapType 0, tiled2LinearEnable 0
> 
> ====== BEEP: 4.0.2 build on Nov 23 2014 22:24:30. ======
>         Core:mxc_v4l2_output v4l2_out.39: Bypass IC.
> Real Audio decoder Wrapper  builmxc_v4l2_output v4l2_out.39: Bypass IC.
> d on Nov 18 2014 10:41:40
> file: /usr/lib/imx-mm/audio-codec/wrap/lib_realad_wrap_arm11_elinux.so.1
> CODEC: REALAUDIOD_ARM_01.01.00_ARM11  build on Sep  4 2014 14:37:18.
> fsl_player_play()
> [Playing  (List Repeated)][Vol=01][00:02:54/00:04:07]swapper/0: page allocation failure: order:0, mode:0x200020
> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.53-1.1.0_ga+g67f859d #1
> [<80013b00>] (unwind_backtrace+0x0/0xf4) from [<80011524>] (show_stack+0x10/0x14)
> [<80011524>] (show_stack+0x10/0x14) from [<80094474>] (warn_alloc_failed+0xe0/0x118)
> [<80094474>] (warn_alloc_failed+0xe0/0x118) from [<8009723c>] (__alloc_pages_nodemask+0x640/0x89c)
> [<8009723c>] (__alloc_pages_nodemask+0x640/0x89c) from [<800c13e4>] (new_slab+0x1e4/0x218)
> [<800c13e4>] (new_slab+0x1e4/0x218) from [<8067ef38>] (__slab_alloc.isra.64.constprop.69+0x380/0x590)
> [<8067ef38>] (__slab_alloc.isra.64.constprop.69+0x380/0x590) from [<800c29a8>] (kmem_cache_alloc+0xdc/0x110)
> [<800c29a8>] (kmem_cache_alloc+0xdc/0x110) from [<805197d0>] (build_skb+0x28/0x98)
> [<805197d0>] (build_skb+0x28/0x98) from [<8051c0c8>] (__netdev_alloc_skb+0x54/0xfc)
> [<8051c0c8>] (__netdev_alloc_skb+0x54/0xfc) from [<803ab878>] (fec_enet_rx_napi+0x758/0xa28)
> [<803ab878>] (fec_enet_rx_napi+0x758/0xa28) from [<80527618>] (net_rx_action+0xbc/0x17c)
> [<80527618>] (net_rx_action+0xbc/0x17c) from [<800332ec>] (__do_softirq+0x120/0x200)
> [<800332ec>] (__do_softirq+0x120/0x200) from [<80033460>] (do_softirq+0x50/0x58)
> [<80033460>] (do_softirq+0x50/0x58) from [<800336fc>] (irq_exit+0x9c/0xd0)
> [<800336fc>] (irq_exit+0x9c/0xd0) from [<8000e94c>] (handle_IRQ+0x44/0x90)
> [<8000e94c>] (handle_IRQ+0x44/0x90) from [<80008558>] (gic_handle_irq+0x2c/0x5c)
> [<80008558>] (gic_handle_irq+0x2c/0x5c) from [<8000dc80>] (__irq_svc+0x40/0x70)
> Exception stack(0x80cbff20 to 0x80cbff68)
> ff20: 80cbff68 00003fee b2931c73 00000ee2 b292c14d 00000ee2 81597180 80ccbd68
> ff40: 00000000 00000000 80cbe000 80cbe000 00000017 80cbff68 8005fbd4 80456db0
> ff60: 60010013 ffffffff
> [<8000dc80>] (__irq_svc+0x40/0x70) from [<80456db0>] (cpuidle_enter_state+0x50/0xe0)
> [<80456db0>] (cpuidle_enter_state+0x50/0xe0) from [<80456ef0>] (cpuidle_idle_call+0xb0/0x148)
> [<80456ef0>] (cpuidle_idle_call+0xb0/0x148) from [<8000ec68>] (arch_cpu_idle+0x10/0x54)
> [<8000ec68>] (arch_cpu_idle+0x10/0x54) from [<8005f4a8>] (cpu_startup_entry+0x104/0x150)
> [<8005f4a8>] (cpu_startup_entry+0x104/0x150) from [<80c71a9c>] (start_kernel+0x324/0x330)
> Mem-info:
> DMA per-cpu:
> CPU    0: hi:  186, btch:  31 usd: 208
> CPU    1: hi:  186, btch:  31 usd:   0
> CPU    2: hi:  186, btch:  31 usd:   0
> CPU    3: hi:  186, btch:  31 usd:  97
> active_anon:11642 inactive_anon:331 isolated_anon:0
> active_file:78585 inactive_file:79182 isolated_file:0
> unevictable:0 dirty:0 writeback:0 unstable:0
> free:35948 slab_reclaimable:1318 slab_unreclaimable:2242
> mapped:5698 shmem:367 pagetables:477 bounce:0
> free_cma:35784
> DMA free:143792kB min:3336kB low:4168kB high:5004kB active_anon:46568kB inactive_anon:1324kB active_file:314340kB inactive_file:316728kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1048576kB managed:697164kB mlocked:0kB dirty:0kB writeback:0kB mapped:22792kB shmem:1468kB slab_reclaimable:5272kB slab_unreclaimable:8968kB kernel_stack:1704kB pagetables:1908kB unstable:0kB bounce:0kB free_cma:143136kB writeback_tmp:0kB pages_scanned:51 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> DMA: 4452*4kB (UC) 4382*8kB (UC) 4111*16kB (UC) 786*32kB (UC) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB 0*32768kB = 143792kB
> 158126 total pagecache pages
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  = 0kB
> Total swap = 0kB
> SLUB: Unable to allocate memory on node -1 (gfp=0x20)
>   cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0, min order: 0
>   node 0: slabs: 0, objs: 0, free: 0
> [Playing  (List Repeated)][Vol=01][00:02:56/00:04:07]
> 
> 
> Regards,
> Andy

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
