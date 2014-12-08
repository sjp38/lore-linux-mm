Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 55C4D6B0038
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 22:26:03 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so4378438pad.1
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 19:26:03 -0800 (PST)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0118.outbound.protection.outlook.com. [157.56.110.118])
        by mx.google.com with ESMTPS id gz3si57949673pbb.55.2014.12.07.19.26.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 07 Dec 2014 19:26:00 -0800 (PST)
From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: [Question] page allocation failure
Date: Mon, 8 Dec 2014 03:25:57 +0000
Message-ID: <BLUPR03MB373C60E05B4073C76EBEA62F5640@BLUPR03MB373.namprd03.prod.outlook.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_BLUPR03MB373C60E05B4073C76EBEA62F5640BLUPR03MB373namprd_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, "rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>

--_000_BLUPR03MB373C60E05B4073C76EBEA62F5640BLUPR03MB373namprd_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi, all expert,

I run one case on i.MX6q-sabresd board, and found page allocation failure, =
but the kernel dump show there have free memory, I don't know why does allo=
cate page failed.
Any points or comment are appreciated.

The case:

-          Board: imx6q sabresd board: 1G ddr memory

-          Kernel version: 3.10.53, with CMA enabled

-          After kernel up,  nfs mount one streaming server, and then aplay=
 the streaming in loop.

-          After 1 hours test,  kernel dump page allocation failure,  but n=
etworking and system is active.

-          i.MX6q networking driver:  drivers/net/ethernet/freescale/fec_ma=
in.c

The dump log:

root@imx6qdlsolo:/mnt/src/RVDec/1080#
x800_24fps_1940kbps_a_44.1khz_96.5Kbps_2_Transformers2_h1080p.rmvb -rv9_ra6=
_1920
playbin is employed!
Generate VideoSink overlaysink
set color key:00010203
=3D=3D=3D=3D=3D=3D OVERLAYSINK: 4.0.2 build on Nov 23 2014 22:24:34. =3D=3D=
=3D=3D=3D=3D
fsl_player_init(): Successfully initialize!
fsl_player_set_media_location(): filename=3DRMVB_1080p_30fps_30Mbps_mp3.rmv=
b
[Stopped  (List Repeated)][Vol=3D01][00:00:00/00:00:00]
=3D=3D=3D=3D=3D=3D AIUR: 4.0.2 build on Nov 23 2014 22:24:26. =3D=3D=3D=3D=
=3D=3D
        Core: RMPARSER_03.00.25  build on Nov 14 2014 06:32:48
file: /usr/lib/imx-mm/parser/lib_rm_parser_arm11_elinux.so.3.0
------------------------
    Track 00 [video_0] Enabled
        Duration: 0:01:41.736000000
        Language:
    Mime:
        video/x-pn-realvideo, width=3D(int)1920, height=3D(int)1080, framer=
ate=3D(fraction)30/1, codec_data=3D(buffer)000000225649444f5256343007800438=
000c00000000001e00000148102040008000
------------------------
[INFO]  Product Info: i.MX6Q/D/S
=3D=3D=3D=3D=3D=3D VPUDEC: 4.0.2 build on Nov 23 2014 22:24:42. =3D=3D=3D=
=3D=3D=3D
       wrapper: 1.0.56 (VPUWRAPPER_ARM_LINUX Build on Nov 23 2014 22:19:27)
        vpulib: 5.4.27
        firmware: 3.1.1.46062
------------------------
    Track 01 [audio_0] Enabled
        Duration: 0:01:42.166000000
        Language:
    Mime:
        audio/x-pn-realaudio, channels=3D(int)2, rate=3D(int)44100, frame_b=
it=3D(int)2240, codec_data=3D(buffer)01000003080000250000000000080005
------------------------
[INFO]  bitstreamMode 1, chromaInterleave 1, mapType 0, tiled2LinearEnable =
0

=3D=3D=3D=3D=3D=3D BEEP: 4.0.2 build on Nov 23 2014 22:24:30. =3D=3D=3D=3D=
=3D=3D
        Core: Real Audio decoder Wrapper  build on Nov 18 2014 10:41:40
filmxc_v4l2_output v4l2_out.39: Bypass IC.
e: /usr/lib/imx-mm/audio-codec/wrmxc_v4l2_output v4l2_out.39: Bypass IC.
ap/lib_realad_wrap_arm11_elinux.so.1
CODEC: REALAUDIOD_ARM_01.01.00_ARM11  build on Sep  4 2014 14:37:18.
fsl_player_play()

FSL_PLAYER_01.00_LINUX build on Nov 23 2014 22:24:47
        [h]display the operation Help
        [p]Play
        [s]Stop
        [e]Seek
        [a]Pause when playing, play when paused
        [v]Volume
        [m]Switch to mute or not
        [>]Play next file
        [<]Play previous file
        [r]Switch to repeated mode or not
        [f]Set full screen or not
        [z]resize the width and height
        [t]Rotate
        [c]Setting play rate
        [i]Display the metadata
        [x]eXit
[Playing  (List Repeated)][Vol=3D01][00:01:41/00:01:42]EOS Found!
FSL_PLAYER_UI_MSG_EOS
Total showed frames (3049), display master blited (3049), playing for (0:01=
:42.130724000), fps (29.854).
fsl_player_stop()
RV9_1920x1080_23.976fps_6059kbps_RV6_44.1khz_96.5kbps_2ch.rmvb
fsl_player_stop()
fsl_player_set_media_location(): filename=3DRV9_1920x1080_23.976fps_6059kbp=
s_RV6_44.1khz_96.5kbps_2ch.rmvb

=3D=3D=3D=3D=3D=3D AIUR: 4.0.2 build on Nov 23 2014 22:24:26. =3D=3D=3D=3D=
=3D=3D
        Core: RMPARSER_03.00.25  build on Nov 14 2014 06:32:48
file: /usr/lib/imx-mm/parser/lib_rm_parser_arm11_elinux.so.3.0
------------------------
    Track 00 [video_0] Enabled
        Duration: 0:04:00.783000000
        Language:
    Mime:
        video/x-pn-realvideo, width=3D(int)1920, height=3D(int)1080, framer=
ate=3D(fraction)785645/32768, codec_data=3D(buffer)000000225649444f52563430=
07800438000c000000000017f9da0148102040008000
------------------------
[INFO]  Product Info: i.MX6Q/D/S
=3D=3D=3D=3D=3D=3D VPUDEC: 4.0.2 build on Nov 23 2014 22:24:42. =3D=3D=3D=
=3D=3D=3D
        wrapper: 1.0.56 (VPUWRAPPER_ARM_LINUX Build on Nov 23 2014 22:19:27=
)
        vpulib: 5.4.27
        firmware: 3.1.1.46062
------------------------
    Track 01 [audio_0] Enabled
        Duration: 0:04:01.486000000
        Language:
    Mime:
        audio/x-pn-realaudio, channels=3D(int)2, rate=3D(int)44100, frame_b=
it=3D(int)2240, codec_data=3D(buffer)01000003080000250000000000080005
------------------------
[INFO]  bitstreamMode 1, chromaInterleave 1, mapType 0, tiled2LinearEnable =
0

=3D=3D=3D=3D=3D=3D BEEP: 4.0.2 build on Nov 23 2014 22:24:30. =3D=3D=3D=3D=
=3D=3D
        Core:mxc_v4l2_output v4l2_out.39: Bypass IC.
Real Audio decoder Wrapper  builmxc_v4l2_output v4l2_out.39: Bypass IC.
d on Nov 18 2014 10:41:40
file: /usr/lib/imx-mm/audio-codec/wrap/lib_realad_wrap_arm11_elinux.so.1
CODEC: REALAUDIOD_ARM_01.01.00_ARM11  build on Sep  4 2014 14:37:18.
fsl_player_play()
[Playing  (List Repeated)][Vol=3D01][00:04:00/00:04:01]EOS Found!
FSL_PLAYER_UI_MSG_EOS
Total showed frames (5774), display master blited (5774), playing for (0:04=
:01.448752000), fps (23.914).
[Playing  (List Repeated)][Vol=3D01][00:00:00/00:00:00]fsl_player_stop()
rv10_ra6_1920x1080_24fps_5495kbps_a_44.1khz_44.1Kbps_2_avatar-fte1_h1080p.r=
mvb
fsl_player_stop()
fsl_player_set_media_location(): filename=3Drv10_ra6_1920x1080_24fps_5495kb=
ps_a_44.1khz_44.1Kbps_2_avatar-fte1_h1080p.rmvb

=3D=3D=3D=3D=3D=3D AIUR: 4.0.2 build on Nov 23 2014 22:24:26. =3D=3D=3D=3D=
=3D=3D
        Core: RMPARSER_03.00.25  build on Nov 14 2014 06:32:48
file: /usr/lib/imx-mm/parser/lib_rm_parser_arm11_elinux.so.3.0
------------------------
    Track 00 [video_0] Enabled
        Duration: 0:04:06.749000000
        Language:
    Mime:
        video/x-pn-realvideo, width=3D(int)1920, height=3D(int)1080, framer=
ate=3D(fraction)1571291/65536, codec_data=3D(buffer)000000225649444f5256343=
007800438000c000000000017f9db0108102040008000
------------------------
[INFO]  Product Info: i.MX6Q/D/S
=3D=3D=3D=3D=3D=3D VPUDEC: 4.0.2 build on Nov 23 2014 22:24:42. =3D=3D=3D=
=3D=3D=3D
        wrapper: 1.0.56 (VPUWRAPPER_ARM_LINUX Build on Nov 23 2014 22:19:27=
)
        vpulib: 5.4.27
        firmware: 3.1.1.46062
------------------------
    Track 01 [audio_0] Enabled
        Duration: 0:04:07.059000000
        Language:
    Mime:
        audio/x-pn-realaudio, channels=3D(int)2, rate=3D(int)44100, frame_b=
it=3D(int)1024, codec_data=3D(buffer)01000003080000250000000000020004
------------------------
[INFO]  bitstreamMode 1, chromaInterleave 1, mapType 0, tiled2LinearEnable =
0

=3D=3D=3D=3D=3D=3D BEEP: 4.0.2 build on Nov 23 2014 22:24:30. =3D=3D=3D=3D=
=3D=3D
        Core:mxc_v4l2_output v4l2_out.39: Bypass IC.
Real Audio decoder Wrapper  builmxc_v4l2_output v4l2_out.39: Bypass IC.
d on Nov 18 2014 10:41:40
file: /usr/lib/imx-mm/audio-codec/wrap/lib_realad_wrap_arm11_elinux.so.1
CODEC: REALAUDIOD_ARM_01.01.00_ARM11  build on Sep  4 2014 14:37:18.
fsl_player_play()
[Playing  (List Repeated)][Vol=3D01][00:02:54/00:04:07]swapper/0: page allo=
cation failure: order:0, mode:0x200020
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.53-1.1.0_ga+g67f859d #1
[<80013b00>] (unwind_backtrace+0x0/0xf4) from [<80011524>] (show_stack+0x10=
/0x14)
[<80011524>] (show_stack+0x10/0x14) from [<80094474>] (warn_alloc_failed+0x=
e0/0x118)
[<80094474>] (warn_alloc_failed+0xe0/0x118) from [<8009723c>] (__alloc_page=
s_nodemask+0x640/0x89c)
[<8009723c>] (__alloc_pages_nodemask+0x640/0x89c) from [<800c13e4>] (new_sl=
ab+0x1e4/0x218)
[<800c13e4>] (new_slab+0x1e4/0x218) from [<8067ef38>] (__slab_alloc.isra.64=
.constprop.69+0x380/0x590)
[<8067ef38>] (__slab_alloc.isra.64.constprop.69+0x380/0x590) from [<800c29a=
8>] (kmem_cache_alloc+0xdc/0x110)
[<800c29a8>] (kmem_cache_alloc+0xdc/0x110) from [<805197d0>] (build_skb+0x2=
8/0x98)
[<805197d0>] (build_skb+0x28/0x98) from [<8051c0c8>] (__netdev_alloc_skb+0x=
54/0xfc)
[<8051c0c8>] (__netdev_alloc_skb+0x54/0xfc) from [<803ab878>] (fec_enet_rx_=
napi+0x758/0xa28)
[<803ab878>] (fec_enet_rx_napi+0x758/0xa28) from [<80527618>] (net_rx_actio=
n+0xbc/0x17c)
[<80527618>] (net_rx_action+0xbc/0x17c) from [<800332ec>] (__do_softirq+0x1=
20/0x200)
[<800332ec>] (__do_softirq+0x120/0x200) from [<80033460>] (do_softirq+0x50/=
0x58)
[<80033460>] (do_softirq+0x50/0x58) from [<800336fc>] (irq_exit+0x9c/0xd0)
[<800336fc>] (irq_exit+0x9c/0xd0) from [<8000e94c>] (handle_IRQ+0x44/0x90)
[<8000e94c>] (handle_IRQ+0x44/0x90) from [<80008558>] (gic_handle_irq+0x2c/=
0x5c)
[<80008558>] (gic_handle_irq+0x2c/0x5c) from [<8000dc80>] (__irq_svc+0x40/0=
x70)
Exception stack(0x80cbff20 to 0x80cbff68)
ff20: 80cbff68 00003fee b2931c73 00000ee2 b292c14d 00000ee2 81597180 80ccbd=
68
ff40: 00000000 00000000 80cbe000 80cbe000 00000017 80cbff68 8005fbd4 80456d=
b0
ff60: 60010013 ffffffff
[<8000dc80>] (__irq_svc+0x40/0x70) from [<80456db0>] (cpuidle_enter_state+0=
x50/0xe0)
[<80456db0>] (cpuidle_enter_state+0x50/0xe0) from [<80456ef0>] (cpuidle_idl=
e_call+0xb0/0x148)
[<80456ef0>] (cpuidle_idle_call+0xb0/0x148) from [<8000ec68>] (arch_cpu_idl=
e+0x10/0x54)
[<8000ec68>] (arch_cpu_idle+0x10/0x54) from [<8005f4a8>] (cpu_startup_entry=
+0x104/0x150)
[<8005f4a8>] (cpu_startup_entry+0x104/0x150) from [<80c71a9c>] (start_kerne=
l+0x324/0x330)
Mem-info:
DMA per-cpu:
CPU    0: hi:  186, btch:  31 usd: 208
CPU    1: hi:  186, btch:  31 usd:   0
CPU    2: hi:  186, btch:  31 usd:   0
CPU    3: hi:  186, btch:  31 usd:  97
active_anon:11642 inactive_anon:331 isolated_anon:0
active_file:78585 inactive_file:79182 isolated_file:0
unevictable:0 dirty:0 writeback:0 unstable:0
free:35948 slab_reclaimable:1318 slab_unreclaimable:2242
mapped:5698 shmem:367 pagetables:477 bounce:0
free_cma:35784
DMA free:143792kB min:3336kB low:4168kB high:5004kB active_anon:46568kB ina=
ctive_anon:1324kB active_file:314340kB inactive_file:316728kB unevictable:0=
kB isolated(anon):0kB isolated(file):0kB present:1048576kB managed:697164kB=
 mlocked:0kB dirty:0kB writeback:0kB mapped:22792kB shmem:1468kB slab_recla=
imable:5272kB slab_unreclaimable:8968kB kernel_stack:1704kB pagetables:1908=
kB unstable:0kB bounce:0kB free_cma:143136kB writeback_tmp:0kB pages_scanne=
d:51 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 4452*4kB (UC) 4382*8kB (UC) 4111*16kB (UC) 786*32kB (UC) 0*64kB 0*128k=
B 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB 0*32768kB =
=3D 143792kB
158126 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  =3D 0kB
Total swap =3D 0kB
SLUB: Unable to allocate memory on node -1 (gfp=3D0x20)
  cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0,=
 min order: 0
  node 0: slabs: 0, objs: 0, free: 0
[Playing  (List Repeated)][Vol=3D01][00:02:56/00:04:07]


Regards,
Andy

--_000_BLUPR03MB373C60E05B4073C76EBEA62F5640BLUPR03MB373namprd_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 12 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:\5B8B\4F53;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:"\@\5B8B\4F53";
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph
	{mso-style-priority:34;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.5in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.25in 1.0in 1.25in;}
div.WordSection1
	{page:WordSection1;}
/* List Definitions */
@list l0
	{mso-list-id:2029332198;
	mso-list-type:hybrid;
	mso-list-template-ids:-1884629102 -765536820 67698691 67698693 67698689 67=
698691 67698693 67698689 67698691 67698693;}
@list l0:level1
	{mso-level-start-at:0;
	mso-level-number-format:bullet;
	mso-level-text:-;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:"Calibri","sans-serif";
	mso-fareast-font-family:\5B8B\4F53;
	mso-bidi-font-family:"Times New Roman";}
@list l0:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"EN-US" link=3D"blue" vlink=3D"purple">
<div class=3D"WordSection1">
<p class=3D"MsoNormal">Hi, all expert,<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">I run one case on i.MX6q-sabresd board, and found pa=
ge allocation failure, but the kernel dump show there have free memory, I d=
on&#8217;t know why does allocate page failed.<o:p></o:p></p>
<p class=3D"MsoNormal">Any points or comment are appreciated.<o:p></o:p></p=
>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">The case:<o:p></o:p></p>
<p class=3D"MsoListParagraph" style=3D"text-indent:-.25in;mso-list:l0 level=
1 lfo1"><![if !supportLists]><span style=3D"mso-list:Ignore">-<span style=
=3D"font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;
</span></span><![endif]>Board: imx6q sabresd board: 1G ddr memory<o:p></o:p=
></p>
<p class=3D"MsoListParagraph" style=3D"text-indent:-.25in;mso-list:l0 level=
1 lfo1"><![if !supportLists]><span style=3D"mso-list:Ignore">-<span style=
=3D"font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;
</span></span><![endif]>Kernel version: 3.10.53, with CMA enabled<o:p></o:p=
></p>
<p class=3D"MsoListParagraph" style=3D"text-indent:-.25in;mso-list:l0 level=
1 lfo1"><![if !supportLists]><span style=3D"mso-list:Ignore">-<span style=
=3D"font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;
</span></span><![endif]>After kernel up,&nbsp; nfs mount one streaming serv=
er, and then aplay the streaming in loop.<o:p></o:p></p>
<p class=3D"MsoListParagraph" style=3D"text-indent:-.25in;mso-list:l0 level=
1 lfo1"><![if !supportLists]><span style=3D"mso-list:Ignore">-<span style=
=3D"font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;
</span></span><![endif]>After 1 hours test,&nbsp; kernel dump page allocati=
on failure,&nbsp; but networking and system is active.<o:p></o:p></p>
<p class=3D"MsoListParagraph" style=3D"text-indent:-.25in;mso-list:l0 level=
1 lfo1"><![if !supportLists]><span style=3D"mso-list:Ignore">-<span style=
=3D"font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;
</span></span><![endif]>i.MX6q networking driver:&nbsp; drivers/net/etherne=
t/freescale/fec_main.c<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">The dump log:<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">root@imx6qdlsolo:/mnt/src/RVDec/1080#<o:p></o:=
p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">x800_24fps_1940kbps_a_44.1khz_96.5Kbps_2_Trans=
formers2_h1080p.rmvb -rv9_ra6_1920<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">playbin is employed!<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">Generate VideoSink overlaysink<o:p></o:p></spa=
n></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">set color key:00010203<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">=3D=3D=3D=3D=3D=3D OVERLAYSINK: 4.0.2 build on=
 Nov 23 2014 22:24:34. =3D=3D=3D=3D=3D=3D<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">fsl_player_init(): Successfully initialize!<o:=
p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">fsl_player_set_media_location(): filename=3DRM=
VB_1080p_30fps_30Mbps_mp3.rmvb<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[Stopped&nbsp; (List Repeated)][Vol=3D01][00:0=
0:00/00:00:00]<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">=3D=3D=3D=3D=3D=3D AIUR: 4.0.2 build on Nov 23=
 2014 22:24:26. =3D=3D=3D=3D=3D=3D<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Cor=
e: RMPARSER_03.00.25 &nbsp;build on Nov 14 2014 06:32:48<o:p></o:p></span><=
/p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">file: /usr/lib/imx-mm/parser/lib_rm_parser_arm=
11_elinux.so.3.0<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">------------------------<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp; Track 00 [video_0] Enabled<=
o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Dur=
ation: 0:01:41.736000000<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lan=
guage:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp; Mime:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vid=
eo/x-pn-realvideo, width=3D(int)1920, height=3D(int)1080, framerate=3D(frac=
tion)30/1, codec_data=3D(buffer)000000225649444f5256343007800438000c0000000=
0001e00000148102040008000<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">------------------------<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[INFO]&nbsp; Product Info: i.MX6Q/D/S<o:p></o:=
p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">=3D=3D=3D=3D=3D=3D VPUDEC: 4.0.2 build on Nov =
23 2014 22:24:42. =3D=3D=3D=3D=3D=3D<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;wrap=
per: 1.0.56 (VPUWRAPPER_ARM_LINUX Build on Nov 23 2014 22:19:27)<o:p></o:p>=
</span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vpu=
lib: 5.4.27<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; fir=
mware: 3.1.1.46062<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">------------------------<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp; Track 01 [audio_0] Enabled<=
o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Dur=
ation: 0:01:42.166000000<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lan=
guage:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp; Mime:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;aud=
io/x-pn-realaudio, channels=3D(int)2, rate=3D(int)44100, frame_bit=3D(int)2=
240, codec_data=3D(buffer)01000003080000250000000000080005<o:p></o:p></span=
></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">------------------------<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[INFO]&nbsp; bitstreamMode 1, chromaInterleave=
 1, mapType 0, tiled2LinearEnable 0<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">=3D=3D=3D=3D=3D=3D BEEP: 4.0.2 build on Nov 23=
 2014 22:24:30. =3D=3D=3D=3D=3D=3D<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Cor=
e: Real Audio decoder Wrapper&nbsp; build on Nov 18 2014 10:41:40<o:p></o:p=
></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">filmxc_v4l2_output v4l2_out.39: Bypass IC.<o:p=
></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">e: /usr/lib/imx-mm/audio-codec/wrmxc_v4l2_outp=
ut v4l2_out.39: Bypass IC.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">ap/lib_realad_wrap_arm11_elinux.so.1<o:p></o:p=
></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">CODEC: REALAUDIOD_ARM_01.01.00_ARM11&nbsp; bui=
ld on Sep&nbsp; 4 2014 14:37:18.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">fsl_player_play()<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">FSL_PLAYER_01.00_LINUX build on Nov 23 2014 22=
:24:47<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [h]=
display the operation Help<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [p]=
Play<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [s]=
Stop<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [e]=
Seek<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [a]=
Pause when playing, play when paused<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [v]=
Volume<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [m]=
Switch to mute or not<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [&g=
t;]Play next file<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [&l=
t;]Play previous file<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [r]=
Switch to repeated mode or not<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [f]=
Set full screen or not<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [z]=
resize the width and height<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [t]=
Rotate<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [c]=
Setting play rate<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [i]=
Display the metadata<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [x]=
eXit<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[Playing&nbsp; (List Repeated)][Vol=3D01][00:0=
1:41/00:01:42]EOS Found!<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">FSL_PLAYER_UI_MSG_EOS<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">Total showed frames (3049), display master bli=
ted (3049), playing for (0:01:42.130724000), fps (29.854).<o:p></o:p></span=
></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">fsl_player_stop()<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">RV9_1920x1080_23.976fps_6059kbps_RV6_44.1khz_9=
6.5kbps_2ch.rmvb<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">fsl_player_stop()<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">fsl_player_set_media_location(): filename=3DRV=
9_1920x1080_23.976fps_6059kbps_RV6_44.1khz_96.5kbps_2ch.rmvb<o:p></o:p></sp=
an></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">=3D=3D=3D=3D=3D=3D AIUR: 4.0.2 build on Nov 23=
 2014 22:24:26. =3D=3D=3D=3D=3D=3D<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Cor=
e: RMPARSER_03.00.25&nbsp; build on Nov 14 2014 06:32:48<o:p></o:p></span><=
/p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">file: /usr/lib/imx-mm/parser/lib_rm_parser_arm=
11_elinux.so.3.0<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">------------------------<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp; Track 00 [video_0] Enabled<=
o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Dur=
ation: 0:04:00.783000000<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lan=
guage:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp; Mime:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vid=
eo/x-pn-realvideo, width=3D(int)1920, height=3D(int)1080, framerate=3D(frac=
tion)785645/32768, codec_data=3D(buffer)000000225649444f5256343007800438000=
c000000000017f9da0148102040008000<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">------------------------<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[INFO]&nbsp; Product Info: i.MX6Q/D/S<o:p></o:=
p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">=3D=3D=3D=3D=3D=3D VPUDEC: 4.0.2 build on Nov =
23 2014 22:24:42. =3D=3D=3D=3D=3D=3D<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; wra=
pper: 1.0.56 (VPUWRAPPER_ARM_LINUX Build on Nov 23 2014 22:19:27)<o:p></o:p=
></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vpu=
lib: 5.4.27<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; fir=
mware: 3.1.1.46062<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">------------------------<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp; Track 01 [audio_0] Enabled<=
o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Dur=
ation: 0:04:01.486000000<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lan=
guage:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp; Mime:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; aud=
io/x-pn-realaudio, channels=3D(int)2, rate=3D(int)44100, frame_bit=3D(int)2=
240, codec_data=3D(buffer)01000003080000250000000000080005<o:p></o:p></span=
></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">------------------------<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[INFO]&nbsp; bitstreamMode 1, chromaInterleave=
 1, mapType 0, tiled2LinearEnable 0<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">=3D=3D=3D=3D=3D=3D BEEP: 4.0.2 build on Nov 23=
 2014 22:24:30. =3D=3D=3D=3D=3D=3D<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Cor=
e:mxc_v4l2_output v4l2_out.39: Bypass IC.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">Real Audio decoder Wrapper&nbsp; builmxc_v4l2_=
output v4l2_out.39: Bypass IC.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">d on Nov 18 2014 10:41:40<o:p></o:p></span></p=
>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">file: /usr/lib/imx-mm/audio-codec/wrap/lib_rea=
lad_wrap_arm11_elinux.so.1<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">CODEC: REALAUDIOD_ARM_01.01.00_ARM11&nbsp; bui=
ld on Sep&nbsp; 4 2014 14:37:18.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">fsl_player_play()<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[Playing&nbsp; (List Repeated)][Vol=3D01][00:0=
4:00/00:04:01]EOS Found!<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">FSL_PLAYER_UI_MSG_EOS<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">Total showed frames (5774), display master bli=
ted (5774), playing for (0:04:01.448752000), fps (23.914).<o:p></o:p></span=
></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[Playing&nbsp; (List Repeated)][Vol=3D01][00:0=
0:00/00:00:00]fsl_player_stop()<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">rv10_ra6_1920x1080_24fps_5495kbps_a_44.1khz_44=
.1Kbps_2_avatar-fte1_h1080p.rmvb<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">fsl_player_stop()<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">fsl_player_set_media_location(): filename=3Drv=
10_ra6_1920x1080_24fps_5495kbps_a_44.1khz_44.1Kbps_2_avatar-fte1_h1080p.rmv=
b<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">=3D=3D=3D=3D=3D=3D AIUR: 4.0.2 build on Nov 23=
 2014 22:24:26. =3D=3D=3D=3D=3D=3D<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Cor=
e: RMPARSER_03.00.25&nbsp; build on Nov 14 2014 06:32:48<o:p></o:p></span><=
/p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">file: /usr/lib/imx-mm/parser/lib_rm_parser_arm=
11_elinux.so.3.0<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">------------------------<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp; Track 00 [video_0] Enabled<=
o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Dur=
ation: 0:04:06.749000000<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lan=
guage:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp; &nbsp;Mime:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vid=
eo/x-pn-realvideo, width=3D(int)1920, height=3D(int)1080, framerate=3D(frac=
tion)1571291/65536, codec_data=3D(buffer)000000225649444f525634300780043800=
0c000000000017f9db0108102040008000<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">------------------------<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[INFO]&nbsp; Product Info: i.MX6Q/D/S<o:p></o:=
p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">=3D=3D=3D=3D=3D=3D VPUDEC: 4.0.2 build on Nov =
23 2014 22:24:42. =3D=3D=3D=3D=3D=3D<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; wra=
pper: 1.0.56 (VPUWRAPPER_ARM_LINUX Build on Nov 23 2014 22:19:27)<o:p></o:p=
></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vpu=
lib: 5.4.27<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; fir=
mware: 3.1.1.46062<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">------------------------<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp; Track 01 [audio_0] Enabled<=
o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Dur=
ation: 0:04:07.059000000<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lan=
guage:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp; Mime:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; aud=
io/x-pn-realaudio, channels=3D(int)2, rate=3D(int)44100, frame_bit=3D(int)1=
024, codec_data=3D(buffer)01000003080000250000000000020004<o:p></o:p></span=
></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">------------------------<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[INFO]&nbsp; bitstreamMode 1, chromaInterleave=
 1, mapType 0, tiled2LinearEnable 0<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">=3D=3D=3D=3D=3D=3D BEEP: 4.0.2 build on Nov 23=
 2014 22:24:30. =3D=3D=3D=3D=3D=3D<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Cor=
e:mxc_v4l2_output v4l2_out.39: Bypass IC.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">Real Audio decoder Wrapper&nbsp; builmxc_v4l2_=
output v4l2_out.39: Bypass IC.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">d on Nov 18 2014 10:41:40<o:p></o:p></span></p=
>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">file: /usr/lib/imx-mm/audio-codec/wrap/lib_rea=
lad_wrap_arm11_elinux.so.1<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">CODEC: REALAUDIOD_ARM_01.01.00_ARM11&nbsp; bui=
ld on Sep&nbsp; 4 2014 14:37:18.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">fsl_player_play()<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[Playing&nbsp; (List Repeated)][Vol=3D01][00:0=
2:54/00:04:07]swapper/0: page allocation failure: order:0, mode:0x200020<o:=
p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10=
.53-1.1.0_ga&#43;g67f859d #1<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;80013b00&gt;] (unwind_backtrace&#43;0x0/0=
xf4) from [&lt;80011524&gt;] (show_stack&#43;0x10/0x14)<o:p></o:p></span></=
p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;80011524&gt;] (show_stack&#43;0x10/0x14) =
from [&lt;80094474&gt;] (warn_alloc_failed&#43;0xe0/0x118)<o:p></o:p></span=
></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;80094474&gt;] (warn_alloc_failed&#43;0xe0=
/0x118) from [&lt;8009723c&gt;] (__alloc_pages_nodemask&#43;0x640/0x89c)<o:=
p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;8009723c&gt;] (__alloc_pages_nodemask&#43=
;0x640/0x89c) from [&lt;800c13e4&gt;] (new_slab&#43;0x1e4/0x218)<o:p></o:p>=
</span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;800c13e4&gt;] (new_slab&#43;0x1e4/0x218) =
from [&lt;8067ef38&gt;] (__slab_alloc.isra.64.constprop.69&#43;0x380/0x590)=
<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;8067ef38&gt;] (__slab_alloc.isra.64.const=
prop.69&#43;0x380/0x590) from [&lt;800c29a8&gt;] (kmem_cache_alloc&#43;0xdc=
/0x110)<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;800c29a8&gt;] (kmem_cache_alloc&#43;0xdc/=
0x110) from [&lt;805197d0&gt;] (build_skb&#43;0x28/0x98)<o:p></o:p></span><=
/p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;805197d0&gt;] (build_skb&#43;0x28/0x98) f=
rom [&lt;8051c0c8&gt;] (__netdev_alloc_skb&#43;0x54/0xfc)<o:p></o:p></span>=
</p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;8051c0c8&gt;] (__netdev_alloc_skb&#43;0x5=
4/0xfc) from [&lt;803ab878&gt;] (fec_enet_rx_napi&#43;0x758/0xa28)<o:p></o:=
p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;803ab878&gt;] (fec_enet_rx_napi&#43;0x758=
/0xa28) from [&lt;80527618&gt;] (net_rx_action&#43;0xbc/0x17c)<o:p></o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;80527618&gt;] (net_rx_action&#43;0xbc/0x1=
7c) from [&lt;800332ec&gt;] (__do_softirq&#43;0x120/0x200)<o:p></o:p></span=
></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;800332ec&gt;] (__do_softirq&#43;0x120/0x2=
00) from [&lt;80033460&gt;] (do_softirq&#43;0x50/0x58)<o:p></o:p></span></p=
>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;80033460&gt;] (do_softirq&#43;0x50/0x58) =
from [&lt;800336fc&gt;] (irq_exit&#43;0x9c/0xd0)<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;800336fc&gt;] (irq_exit&#43;0x9c/0xd0) fr=
om [&lt;8000e94c&gt;] (handle_IRQ&#43;0x44/0x90)<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;8000e94c&gt;] (handle_IRQ&#43;0x44/0x90) =
from [&lt;80008558&gt;] (gic_handle_irq&#43;0x2c/0x5c)<o:p></o:p></span></p=
>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;80008558&gt;] (gic_handle_irq&#43;0x2c/0x=
5c) from [&lt;8000dc80&gt;] (__irq_svc&#43;0x40/0x70)<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">Exception stack(0x80cbff20 to 0x80cbff68)<o:p>=
</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">ff20: 80cbff68 00003fee b2931c73 00000ee2 b292=
c14d 00000ee2 81597180 80ccbd68<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">ff40: 00000000 00000000 80cbe000 80cbe000 0000=
0017 80cbff68 8005fbd4 80456db0<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">ff60: 60010013 ffffffff<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;8000dc80&gt;] (__irq_svc&#43;0x40/0x70) f=
rom [&lt;80456db0&gt;] (cpuidle_enter_state&#43;0x50/0xe0)<o:p></o:p></span=
></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;80456db0&gt;] (cpuidle_enter_state&#43;0x=
50/0xe0) from [&lt;80456ef0&gt;] (cpuidle_idle_call&#43;0xb0/0x148)<o:p></o=
:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;80456ef0&gt;] (cpuidle_idle_call&#43;0xb0=
/0x148) from [&lt;8000ec68&gt;] (arch_cpu_idle&#43;0x10/0x54)<o:p></o:p></s=
pan></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;8000ec68&gt;] (arch_cpu_idle&#43;0x10/0x5=
4) from [&lt;8005f4a8&gt;] (cpu_startup_entry&#43;0x104/0x150)<o:p></o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[&lt;8005f4a8&gt;] (cpu_startup_entry&#43;0x10=
4/0x150) from [&lt;80c71a9c&gt;] (start_kernel&#43;0x324/0x330)<o:p></o:p><=
/span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">Mem-info:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">DMA per-cpu:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">CPU&nbsp;&nbsp;&nbsp; 0: hi:&nbsp; 186, btch:&=
nbsp; 31 usd: 208<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">CPU&nbsp;&nbsp;&nbsp; 1: hi:&nbsp; 186, btch:&=
nbsp; 31 usd:&nbsp;&nbsp; 0<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">CPU&nbsp;&nbsp;&nbsp; 2: hi:&nbsp; 186, btch:&=
nbsp; 31 usd:&nbsp;&nbsp; 0<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">CPU&nbsp;&nbsp;&nbsp; 3: hi:&nbsp; 186, btch:&=
nbsp; 31 usd:&nbsp; 97<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">active_anon:11642 inactive_anon:331 isolated_a=
non:0<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">active_file:78585 inactive_file:79182 isolated=
_file:0<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">unevictable:0 dirty:0 writeback:0 unstable:0<o=
:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">free:35948 slab_reclaimable:1318 slab_unreclai=
mable:2242<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">mapped:5698 shmem:367 pagetables:477 bounce:0<=
o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">free_cma:35784<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">DMA free:143792kB min:3336kB low:4168kB high:5=
004kB active_anon:46568kB inactive_anon:1324kB active_file:314340kB inactiv=
e_file:316728kB unevictable:0kB isolated(anon):0kB
 isolated(file):0kB present:1048576kB managed:697164kB mlocked:0kB dirty:0k=
B writeback:0kB mapped:22792kB shmem:1468kB slab_reclaimable:5272kB slab_un=
reclaimable:8968kB kernel_stack:1704kB pagetables:1908kB unstable:0kB bounc=
e:0kB free_cma:143136kB writeback_tmp:0kB
 pages_scanned:51 all_unreclaimable? no<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">lowmem_reserve[]: 0 0 0 0<o:p></o:p></span></p=
>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">DMA: 4452*4kB (UC) 4382*8kB (UC) 4111*16kB (UC=
) 786*32kB (UC) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0=
*8192kB 0*16384kB 0*32768kB =3D 143792kB<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">158126 total pagecache pages<o:p></o:p></span>=
</p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">0 pages in swap cache<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">Swap cache stats: add 0, delete 0, find 0/0<o:=
p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">Free swap&nbsp; =3D 0kB<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">Total swap =3D 0kB<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">SLUB: Unable to allocate memory on node -1 (gf=
p=3D0x20)<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp; cache: kmalloc-192, object size: 192, b=
uffer size: 192, default order: 0, min order: 0<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">&nbsp; node 0: slabs: 0, objs: 0, free: 0<o:p>=
</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.0pt;font-family:&quot;Co=
urier New&quot;;color:black">[Playing&nbsp; (List Repeated)][Vol=3D01][00:0=
2:56/00:04:07]<o:p></o:p></span></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Regards,<o:p></o:p></p>
<p class=3D"MsoNormal">Andy<o:p></o:p></p>
</div>
</body>
</html>

--_000_BLUPR03MB373C60E05B4073C76EBEA62F5640BLUPR03MB373namprd_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
