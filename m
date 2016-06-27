Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 533F86B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 07:07:59 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 13so179405511itl.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 04:07:59 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id 138si6449265itv.94.2016.06.27.04.07.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Jun 2016 04:07:58 -0700 (PDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0O9F013HDG9846A0@mailout3.samsung.com> for linux-mm@kvack.org;
 Mon, 27 Jun 2016 20:07:56 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
Subject: BUG: Kernel 3.10.65: Kernel panic while send-receive MMS on same device
Date: Mon, 27 Jun 2016 16:40:15 +0530
Message-id: <04da01d1d064$7c6efad0$754cf070$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-input@vger.kernel.org
Cc: pintu.k@samsung.com, vishnu.ps@samsung.com, 'CHANDAN VN' <chandan.vn@samsung.com>

Hi,

Need a help or some pointer about this issue.
Yesterday, received one kernel panic issue on one of our mobile device.
Scenario is: Sender is sending an MMS content to its own number. After MMS is
received, device vibrates and immediately went into kernel panic.
We checked and could not found any problem in our vibrator driver.
The PC value itself becomes bad, so we don't have any clue.
swapper/1:    0] [c1] PC is at 0x0
swapper/1:    0] [c1] LR is at ns_to_timeval+0x1c/0x34

Following are few details:
Processor: ARM Cortex-A7 Quad Core
RAM: 1GB
Kernel version: 3.10.65 (custom kernel)

I know it is custom kernel, but no changes are made related to these areas.
It looks like there is some memory corruption issue after returning from the
timer handler.
It looks to be in the generic code which is similar to the mainline version of
3.10 kernel.
If anybody have seen this kind of issue on this kernel version or any other
kernel version, please help us how to debug this issue further to find the root
cause.
If there is already a fix available, please share the details.
Even a little pointer also will be helpful.
If more information is required, please let us know.
Thank you!

<6>[ 2142.740814]  [3:    kworker/3:3: 1457] [c3] [VIB] vib_en off - 0uv
<6>[ 2142.817077]  [1:    kworker/1:2:  114] [c1] [VIB] vib_en on - 3000000uv
<1>[ 2142.883514]  [1:      swapper/1:    0] [c1] Unable to handle kernel NULL
pointer dereference at virtual address 00000000
<1>[ 2142.883544]  [1:      swapper/1:    0] [c1] pgd = c0004000
<1>[ 2142.883575]  [1:      swapper/1:    0] [c1] [00000000] *pgd=aa80d811,
*pte=0000045f, *ppte=0000045e
<0>[ 2142.883605]  [1:      swapper/1:    0] [c1] Internal error: Oops: 80000005
[#1] PREEMPT SMP ARM
<4>[ 2142.883605]  [1:      swapper/1:    0] [c1] Modules linked in:
<4>[ 2142.883636]  [1:      swapper/1:    0] [c1] CPU: 1 PID: 0 Comm: swapper/1
Tainted: G        W    3.10.65 #1-
<4>[ 2142.883666]  [1:      swapper/1:    0] [c1] task: ea06aec0 ti: ea1ec000
task.ti: ea1ec000
<1>[ 2142.883666]  [0:      swapper/0:    0] [c0] Unable to handle kernel NULL
pointer dereference at virtual address 00000000
<1>[ 2142.883697]  [0:      swapper/0:    0] [c0] pgd = c0004000
<1>[ 2142.883697]  [0:      swapper/0:    0] [c0] [00000000] *pgd=aa80d811,
*pte=0000045f, *ppte=0000045e
<4>[ 2142.883728]  [1:      swapper/1:    0] [c1] PC is at 0x0
<4>[ 2142.883728]  [1:      swapper/1:    0] [c1] LR is at
ns_to_timeval+0x1c/0x34
<4>[ 2142.883758]  [1:      swapper/1:    0] [c1] pc : [<00000000>]    lr :
[<c00275cc>]    psr: 20070193
<4>[ 2142.883758]  [1:      swapper/1:    0] sp : ea1edf60  ip : 0043ff66  fp :
00000001
<4>[ 2142.883789]  [1:      swapper/1:    0] [c1] r10: c0a2a3e8  r9 : 00000000
r8 : 00000000
<4>[ 2142.883789]  [1:      swapper/1:    0] [c1] r7 : 000001f2  r6 : ec8c87cc
r5 : 00000001  r4 : 00000000
<4>[ 2142.883819]  [1:      swapper/1:    0] [c1] r3 : 00000000  r2 : 00001167
r1 : 000f4240  r0 : 20070193
<4>[ 2142.883819]  [1:      swapper/1:    0] [c1] Flags: nzCv  IRQs off  FIQs on
Mode SVC_32  ISA ARM  Segment kernel
<4>[ 2142.883850]  [1:      swapper/1:    0] [c1] Control: 10c53c7d  Table:
a60dc06a  DAC: 00000015
<4>[ 2142.883850]  [1:      swapper/1:    0] [c1] 
<4>[ 2142.883850]  [1:      swapper/1:    0] LR: 0xc002754c:
<4>[ 2142.883880]  [1:      swapper/1:    0] [c1] 754c  e8bd8070 e92d4013
e1a04000 e1a01003 e1a00002 e1903001 03a03000 05843000
<4>[ 2142.883911]  [1:      swapper/1:    0] [c1] 756c  0a00000a e28d3004
e59f2030 eb082088 e59d2004 e3520000 b59f3020 b0823003
<4>[ 2142.883941]  [1:      swapper/1:    0] [c1] 758c  b58d3004 e59d3004
b2400001 e5840000 e1a00004 e5843004 e28dd008 e8bd8010
<4>[ 2142.883972]  [1:      swapper/1:    0] [c1] 75ac  3b9aca00 e92d4013
e1a04000 e1a0000d ebffffe3 e3a01ffa e59d0004 eb07f24c
<4>[ 2142.884002]  [1:      swapper/1:    0] [c1] 75cc  e59d3000 e5843000
e5840004 e1a00004 e28dd008 e8bd8010 e59f3044 e590c000
<4>[ 2142.884002]  [1:      swapper/1:    0] [c1] 75ec  e5902004 e15c0003
e59f0038 9243392d 9243308a 83a03000 90823003 859fc028
<4>[ 2142.884033]  [1:      swapper/1:    0] [c1] 760c  e0c10093 e1a02ea0
e1a03ea1 e1822181 e3a01332 e0a32c91 e1a00ca2 e1800383
<4>[ 2142.884063]  [1:      swapper/1:    0] [c1] 762c  e12fff1e 00a3d709
6b5fca6b 00a3d70a e92d4037 e2505000 e1a04001 0a000010
<4>[ 2142.884094]  [1:      swapper/1:    0] [c1] 
<4>[ 2142.884094]  [1:      swapper/1:    0] SP: 0xea1edee0:
<4>[ 2142.884124]  [1:      swapper/1:    0] [c1] dee0  f1cfff4c eb7a3778
eb7a3780 c0053d04 00000000 00000000 ffffffff 00000000
<4>[ 2142.884155]  [1:      swapper/1:    0] [c1] df00  00000002 00000000
20070193 ffffffff ea1edf4c c000e478 20070193 000f4240
<4>[ 2142.884155]  [1:      swapper/1:    0] [c1] df20  00001167 00000000
00000000 00000001 ec8c87cc 000001f2 00000000 00000000
<4>[ 2142.884185]  [1:      swapper/1:    0] [c1] df40  c0a2a3e8 00000001
0043ff66 ea1edf60 c00275cc 00000000 20070193 ffffffff
<1>[ 2142.884246]  [2:      swapper/2:    0] Unable to handle kernel NULL
pointer dereference at virtual address 00000000
<1>[ 2142.884246]  [2:      swapper/2:    0] [c2] pgd = c0004000
<4>[ 2142.884216]  [2:      swapper/2:    0] [c1] df60  ecd0845a 000001f2
0000000f 00000001 00000000 00001167 ea1ec000 c1563758
[c2] [00000000] *pgd=aa80d811, *pte=0000045f, *ppte=0000045e<4>[ 2142.884307]
[2:      swapper/2:    0] 
<4>[ 2142.884307]  [1:      swapper/1:    0] [c1] 
<4>[ 2142.884307]  [1:      swapper/1:    0] [c1] df80  c0a2a3e8 ec8c87cc
000001f2 c04524fc ec8c87cc 000001f2 00000000 00000001
<4>[ 2142.884338]  [1:      swapper/1:    0] [c1] dfa0  c1563758 00000000
ea1ec000 ea1ec000 c0a411ec 00000000 c0a2a3e8 c0452708
<4>[ 2142.884368]  [1:      swapper/1:    0] [c1] dfc0  0004e0b2 ea1ec000
ea1ec000 ea1ec030 c0a4358c 8000406a 410fc075 00000000
<4>[ 2142.884399]  [1:      swapper/1:    0] [c1] 
<4>[ 2142.884399]  [1:      swapper/1:    0] R6: 0xec8c874c:
<4>[ 2142.884429]  [1:      swapper/1:    0] [c1] 874c  35363233 12232634
26343536 3311012b 73433d02 2827eb67 03460328 a44a474f
<4>[ 2142.884460]  [1:      swapper/1:    0] [c1] 876c  fe5c7065 4543a4e3
456f4547 ccc84547 48596d01 92026c60 170f2627 4c44160f
<4>[ 2142.884460]  [1:      swapper/1:    0] [c1] 878c  1b765d68 3efc1301
fd42403c 434346b2 00f0fe44 6200ffff 4e025aff 2202d402
<4>[ 2142.884490]  [1:      swapper/1:    0] [c1] 87ac  00003900 060a0300
00006602 1d000300 4e020000 1300d402 29001c00 49404c00
<4>[ 2142.884521]  [1:      swapper/1:    0] [c1] 87cc  04060113 04004a01
04020600 01076106 01010802 61010209 0505010a 03005903
<4>[ 2142.884551]  [1:      swapper/1:    0] [c1] 87ec  0b4b6503 00090901
00000059 1d4c0066 1d14141d 27281d29 23242526 141c1421
<4>[ 2142.884582]  [1:      swapper/1:    0] [c1] 880c  1131261b 0b0c3411
16002b19 2b061415 35233502 013b1133 14151632 33150107
<4>[ 2142.884613]  [1:      swapper/1:    0] [c1] 882c  34353632 36122326
2b263435 15331501 02331523 6773430b 454527eb 7065a44a
<4>[ 2142.884643]  [1:      swapper/1:    0] [c1] 
<4>[ 2142.884643]  [1:      swapper/1:    0] R10: 0xc0a2a368:
<4>[ 2142.884643]  [1:      swapper/1:    0] [c1] a368  00000000 00000000
00000000 00000000 00000000 00000000 00124f80 00118c30
<4>[ 2142.884674]  [1:      swapper/1:    0] [c1] a388  0010c8e0 0010c8e0
000f4240 00000000 00000000 00000000 00000000 00000000
<4>[ 2142.884704]  [1:      swapper/1:    0] [c1] a3a8  00000001 00040004
c0a2a3b0 c0a2a3b0 00000000 00000000 c0a24194 00000000
<4>[ 2142.884735]  [1:      swapper/1:    0] [c1] a3c8  00000002 00000005
00000000 d530d530 c0a2a3d8 c0a2a3d8 c0a0a62c 00000001
<4>[ 2142.884765]  [1:      swapper/1:    0] [c1] a3e8  c08e0456 00000000
00000000 00000000 00003143 00000000 00000000 00000000
<4>[ 2142.884765]  [1:      swapper/1:    0] [c1] a408  6e617473 00796264
00000000 00000000 00000000 00000000 00000000 00000000
<4>[ 2142.884796]  [1:      swapper/1:    0] [c1] a428  00000001 00000001
00000000 00000001 00000000 c04b5a2c 00000000 00003243
<4>[ 2142.884826]  [1:      swapper/1:    0] [c1] a448  00000000 00000000
00000000 6c735f6c 00706565 00000000 00000000 00000000
<0>[ 2142.884857]  [1:      swapper/1:    0] [c1] Process swapper/1 (pid: 0,
stack limit = 0xea1ec238)
<0>[ 2142.884857]  [1:      swapper/1:    0] [c1] Stack: (0xea1edf60 to
0xea1ee000)
<0>[ 2142.884887]  [1:      swapper/1:    0] [c1] df60: ecd0845a 000001f2
0000000f 00000001 00000000 00001167 ea1ec000 c1563758
<0>[ 2142.884918]  [1:      swapper/1:    0] [c1] df80: c0a2a3e8 ec8c87cc
000001f2 c04524fc ec8c87cc 000001f2 00000000 00000001
<0>[ 2142.884948]  [1:      swapper/1:    0] [c1] dfa0: c1563758 00000000
ea1ec000 ea1ec000 c0a411ec 00000000 c0a2a3e8 c0452708
<0>[ 2142.884948]  [1:      swapper/1:    0] [c1] dfc0: 0004e0b2 ea1ec000
ea1ec000 ea1ec030 c0a4358c 8000406a 410fc075 00000000
<0>[ 2142.884979]  [1:      swapper/1:    0] [c1] dfe0: 00000000 c000f4ec
ea1ec000 c005eab4 c0a4358c 8069ac44 ffbfffff efff9fe7
<4>[ 2142.885009]  [1:      swapper/1:    0] [c1] [<c00275cc>]
(ns_to_timeval+0x1c/0x34) from [<00000001>] (0x1)
<0>[ 2142.885009]  [1:      swapper/1:    0] [c1] Code: bad PC value
<4>[ 2142.885040]  [1:      swapper/1:    0] [c1] ---[ end trace
69cf41cae374fe57 ]---
<0>[ 2142.885040]  [0:      swapper/0:    0] [c0] Internal error: Oops: 80000005
[#2] PREEMPT SMP ARM
<4>[ 2142.885070]  [0:      swapper/0:    0] [c0] Modules linked in:
<4>[ 2142.885070]  [0:      swapper/0:    0] [c0] CPU: 0 PID: 0 Comm: swapper/0
Tainted: G      D W    3.10.65 #1-
<4>[ 2142.885101]  [0:      swapper/0:    0] [c0] task: c09ed538 ti: c09c6000
task.ti: c09c6000
<4>[ 2142.885101]  [0:      swapper/0:    0] [c0] PC is at 0x0
<4>[ 2142.885131]  [0:      swapper/0:    0] [c0] LR is at
ns_to_timeval+0x1c/0x34
<4>[ 2142.885131]  [0:      swapper/0:    0] [c0] pc : [<00000000>]    lr :
[<c00275cc>]    psr: 200f0193
<4>[ 2142.885131]  [0:      swapper/0:    0] sp : c09c7f30  ip : 0038cc60  fp :
00000000
<4>[ 2142.885162]  [0:      swapper/0:    0] [c0] r10: c0a2a3e8  r9 : 00000000
r8 : 00000000
<4>[ 2142.885192]  [0:      swapper/0:    0] [c0] r7 : 000001f2  r6 : ec9a08de
r5 : 00000000  r4 : 00000000
<4>[ 2142.885192]  [0:      swapper/0:    0] [c0] r3 : 00000000  r2 : 00000e8b
r1 : 000f4240  r0 : 200f0193
<4>[ 2142.885223]  [0:      swapper/0:    0] [c0] Flags: nzCv  IRQs off  FIQs on
Mode SVC_32  ISA ARM  Segment kernel
<4>[ 2142.885223]  [0:      swapper/0:    0] [c0] Control: 10c53c7d  Table:
a6cb806a  DAC: 00000015
<4>[ 2142.885253]  [0:      swapper/0:    0] [c0] 
<4>[ 2142.885253]  [0:      swapper/0:    0] LR: 0xc002754c:
<0>[ 2142.885284]  [1:      swapper/1:    0] Kernel panic - not syncing:
Attempted to kill the idle task!
<4>[ 2142.885253]  [1:      swapper/1:    0] [c0] 754c  e8bd8070 e92d4013[c0]
e1a04000 e1a01003
Modules linked in: e1a00002<4>[ 2142.885314]  [0:      swapper/0:    0]
e1903001 03a03000 05843000
<4>[ 2142.885314]  [1:      swapper/1:    0] [c1] 
<1>[ 2142.885345]  [3:    dlog_logger:  509] [c3] Unable to handle kernel NULL
pointer dereference at virtual address 00000000
<1>[ 2142.885345]  [3:    dlog_logger:  509] [c3] pgd = e66b8000
<1>[ 2142.885375]  [3:    dlog_logger:  509] [c3] [00000000] *pgd=00000000
<4>[ 2142.885375]  [0:      swapper/0:    0] [c0] 756c  0a00000a e28d3004
e59f2030 eb082088 e59d2004 e3520000 b59f3020 b0823003
<4>[ 2142.885406]  [0:      swapper/0:    0] [c0] 758c  b58d3004 e59d3004
b2400001 e5840000 e1a00004 e5843004 e28dd008 e8bd8010
<4>[ 2142.885437]  [0:      swapper/0:    0] [c0] 75ac  3b9aca00 e92d4013
e1a04000 e1a0000d ebffffe3 e3a01ffa e59d0004 eb07f24c
<4>[ 2142.885467]  [0:      swapper/0:    0] [c0] 75cc  e59d3000 e5843000
e5840004 e1a00004 e28dd008 e8bd8010 e59f3044 e590c000
<4>[ 2142.885498]  [0:      swapper/0:    0] [c0] 75ec  e5902004 e15c0003
e59f0038 9243392d 9243308a 83a03000 90823003 859fc028
<4>[ 2142.885528]  [0:      swapper/0:    0] [c0] 760c  e0c10093 e1a02ea0
e1a03ea1 e1822181 e3a01332 e0a32c91 e1a00ca2 e1800383
<4>[ 2142.885528]  [0:      swapper/0:    0] [c0] 762c  e12fff1e 00a3d709
6b5fca6b 00a3d70a e92d4037 e2505000 e1a04001 0a000010
<4>[ 2142.885559]  [0:      swapper/0:    0] [c0] 
<4>[ 2142.885559]  [0:      swapper/0:    0] SP: 0xc09c7eb0:
<4>[ 2142.885589]  [0:      swapper/0:    0] [c0] 7eb0  f1cfff30 e6e9bbb8
e6e9bbc0 c0053d04 00000000 00000000 ffffffff 00000000
<4>[ 2142.885620]  [0:      swapper/0:    0] [c0] 7ed0  00000002 00000000
200f0193 ffffffff c09c7f1c c000e478 200f0193 000f4240
<4>[ 2142.885650]  [0:      swapper/0:    0] [c0] 7ef0  00000e8b 00000000
00000000 00000000 ec9a08de 000001f2 00000000 00000000
<4>[ 2142.885681]  [0:      swapper/0:    0] [c0] 7f10  c0a2a3e8 00000000
0038cc60 c09c7f30 c00275cc 00000000 200f0193 ffffffff
<4>[ 2142.885681]  [0:      swapper/0:    0] [c0] 7f30  ecd2d866 000001f2
00000056 00000000 00000000 00000e8b c09c6000 c155a758
<4>[ 2142.885711]  [0:      swapper/0:    0] [c0] 7f50  c0a2a3e8 ec9a08de
000001f2 c04524fc ec9a08de 000001f2 00000000 00000001
<4>[ 2142.885742]  [0:      swapper/0:    0] [c0] 7f70  c155a758 00000000
c09c6010 c09c6000 c0a411ec 00000000 c0a2a3e8 c0452708
<4>[ 2142.885772]  [0:      swapper/0:    0] [c0] 7f90  0011cd78 c09c6000
c09c6000 c09c6000 c15551c0 c09bb208 410fc075 00000000
<4>[ 2142.885803]  [0:      swapper/0:    0] [c0] 
<4>[ 2142.885803]  [0:      swapper/0:    0] R6: 0xec9a085e:
<4>[ 2142.885803]  [0:      swapper/0:    0] [c0] 085c  00264fec 00000017
00265014 00000017 00265018 00000017 0026501c 00000017
<4>[ 2142.885833]  [0:      swapper/0:    0] [c0] 087c  00265044 00000017
00265048 00000017 0026504c 00000017 00265074 00000017
<4>[ 2142.885864]  [0:      swapper/0:    0] [c0] 089c  00265078 00000017
0026507c 00000017 002650a4 00000017 002650a8 00000017
<4>[ 2142.885894]  [0:      swapper/0:    0] [c0] 08bc  002650ac 00000017
002650d4 00000017 002650d8 00000017 002650dc 00000017
<4>[ 2142.885925]  [0:      swapper/0:    0] [c0] 08dc  00265104 00000017
00265108 00000017 0026510c 00000017 00265138 00000017
<4>[ 2142.885955]  [0:      swapper/0:    0] [c0] 08fc  0026513c 00000017
00265168 00000017 00265198 00000017 0026519c 00000017
<4>[ 2142.885955]  [0:      swapper/0:    0] [c0] 091c  002651f8 00000017
002651fc 00000017 00265228 00000017 0026522c 00000017
<4>[ 2142.885986]  [0:      swapper/0:    0] [c0] 093c  00265258 00000017
0026525c 00000017 00265288 00000017 0026528c 00000017
<4>[ 2142.886016]  [0:      swapper/0:    0] [c0] 095c  002652b4 00000017
002652b8 00000017 002652bc 00000017 002652e4 00000017
<4>[ 2142.886047]  [0:      swapper/0:    0] [c0] 
<4>[ 2142.886047]  [0:      swapper/0:    0] R10: 0xc0a2a368:
<4>[ 2142.886077]  [0:      swapper/0:    0] [c0] a368  00000000 00000000
00000000 00000000 00000000 00000000 00124f80 00118c30
<4>[ 2142.886108]  [0:      swapper/0:    0] [c0] a388  0010c8e0 0010c8e0
000f4240 00000000 00000000 00000000 00000000 00000000
<4>[ 2142.886108]  [0:      swapper/0:    0] [c0] a3a8  00000001 00040004
c0a2a3b0 c0a2a3b0 00000000 00000000 c0a24194 00000000
<4>[ 2142.886138]  [0:      swapper/0:    0] [c0] a3c8  00000002 00000005
00000000 d530d530 c0a2a3d8 c0a2a3d8 c0a0a62c 00000001
<4>[ 2142.886169]  [0:      swapper/0:    0] [c0] a3e8  c08e0456 00000000
00000000 00000000 00003143 00000000 00000000 00000000
<4>[ 2142.886199]  [0:      swapper/0:    0] [c0] a408  6e617473 00796264
00000000 00000000 00000000 00000000 00000000 00000000
<4>[ 2142.886230]  [0:      swapper/0:    0] [c0] a428  00000001 00000001
00000000 00000001 00000000 c04b5a2c 00000000 00003243
<4>[ 2142.886230]  [0:      swapper/0:    0] [c0] a448  00000000 00000000
00000000 6c735f6c 00706565 00000000 00000000 00000000
<0>[ 2142.886260]  [0:      swapper/0:    0] [c0] Process swapper/0 (pid: 0,
stack limit = 0xc09c6238)
<0>[ 2142.886291]  [0:      swapper/0:    0] [c0] Stack: (0xc09c7f30 to
0xc09c8000)
<0>[ 2142.886291]  [0:      swapper/0:    0] [c0] 7f20:
ecd2d866 000001f2 00000056 00000000
<0>[ 2142.886322]  [0:      swapper/0:    0] [c0] 7f40: 00000000 00000e8b
c09c6000 c155a758 c0a2a3e8 ec9a08de 000001f2 c04524fc
<0>[ 2142.886352]  [0:      swapper/0:    0] [c0] 7f60: ec9a08de 000001f2
00000000 00000001 c155a758 00000000 c09c6010 c09c6000
<0>[ 2142.886352]  [0:      swapper/0:    0] [c0] 7f80: c0a411ec 00000000
c0a2a3e8 c0452708 0011cd78 c09c6000 c09c6000 c09c6000
<0>[ 2142.886383]  [0:      swapper/0:    0] [c0] 7fa0: c15551c0 c09bb208
410fc075 00000000 00000000 c000f4ec c09c6000 c005eab4
<0>[ 2142.886413]  [0:      swapper/0:    0] [c0] 7fc0: c15551c0 c09749f4
ffffffff ffffffff c09744f4 00000000 00000000 c09bb208
<0>[ 2142.886444]  [0:      swapper/0:    0] [c0] 7fe0: 10c53c7d c09e51e8
c09bb204 c09ee3d4 8000406a 8000806c 00000000 00000000
<4>[ 2142.886444]  [0:      swapper/0:    0] [c0] [<c00275cc>]
(ns_to_timeval+0x1c/0x34) from [<00000000>] (  (null))
<0>[ 2142.886474]  [0:      swapper/0:    0] [c0] Code: bad PC value
<4>[ 2142.886474]  [0:      swapper/0:    0] [c0] ---[ end trace
69cf41cae374fe58 ]---
<0>[ 2142.886505]  [2:      swapper/2:    0] [c2] Internal error: Oops: 80000005
[#3] PREEMPT SMP ARM
<4>[ 2142.886505]  [2:      swapper/2:    0] [c2] Modules linked in:
<4>[ 2142.886535]  [2:      swapper/2:    0] [c2] CPU: 2 PID: 0 Comm: swapper/2
Tainted: G      D W    3.10.65 #1-
<4>[ 2142.886535]  [2:      swapper/2:    0] [c2] task: ea06b300 ti: ea1ee000
task.ti: ea1ee000
<4>[ 2142.886566]  [2:      swapper/2:    0] [c2] PC is at 0x0
<4>[ 2142.886566]  [2:      swapper/2:    0] [c2] LR is at
ns_to_timeval+0x1c/0x34
<4>[ 2142.886596]  [2:      swapper/2:    0] [c2] pc : [<00000000>]    lr :
[<c00275cc>]    psr: 200f0193
<4>[ 2142.886596]  [2:      swapper/2:    0] sp : ea1eff60  ip : 003b207c  fp :
00000002
<4>[ 2142.886627]  [2:      swapper/2:    0] [c2] r10: c0a2a3e8  r9 : 00000000
r8 : 00000000
<4>[ 2142.886627]  [2:      swapper/2:    0] [c2] r7 : 000001f2  r6 : eca08dcc
r5 : 00000002  r4 : 00000000
<4>[ 2142.886657]  [2:      swapper/2:    0] [c2] r3 : 00000000  r2 : 00000f23
r1 : 000f4240  r0 : 200f0193
<4>[ 2142.886657]  [2:      swapper/2:    0] [c2] Flags: nzCv  IRQs off  FIQs on
Mode SVC_32  ISA ARM  Segment kernel
<4>[ 2142.886688]  [2:      swapper/2:    0] [c2] Control: 10c53c7d  Table:
a6b8806a  DAC: 00000015
<4>[ 2142.886688]  [2:      swapper/2:    0] [c2] 
<4>[ 2142.886688]  [2:      swapper/2:    0] LR: 0xc002754c:
<4>[ 2142.886718]  [2:      swapper/2:    0] [c2] 754c  e8bd8070 e92d4013
e1a04000 e1a01003 e1a00002 e1903001 03a03000 05843000
<4>[ 2142.886749]  [2:      swapper/2:    0] [c2] 756c  0a00000a e28d3004
e59f2030 eb082088 e59d2004 e3520000 b59f3020 b0823003
<4>[ 2142.886749]  [2:      swapper/2:    0] [c2] 758c  b58d3004 e59d3004
b2400001 e5840000 e1a00004 e5843004 e28dd008 e8bd8010
<4>[ 2142.886779]  [2:      swapper/2:    0] [c2] 75ac  3b9aca00 e92d4013
e1a04000 e1a0000d ebffffe3 e3a01ffa e59d0004 eb07f24c
<4>[ 2142.886810]  [2:      swapper/2:    0] [c2] 75cc  e59d3000 e5843000
e5840004 e1a00004 e28dd008 e8bd8010 e59f3044 e590c000
<4>[ 2142.886840]  [2:      swapper/2:    0] [c2] 75ec  e5902004 e15c0003
e59f0038 9243392d 9243308a 83a03000 90823003 859fc028
<4>[ 2142.886871]  [2:      swapper/2:    0] [c2] 760c  e0c10093 e1a02ea0
e1a03ea1 e1822181 e3a01332 e0a32c91 e1a00ca2 e1800383
<4>[ 2142.886901]  [2:      swapper/2:    0] [c2] 762c  e12fff1e 00a3d709
6b5fca6b 00a3d70a e92d4037 e2505000 e1a04001 0a000010
<4>[ 2142.886932]  [2:      swapper/2:    0] [c2] 
<4>[ 2142.886932]  [2:      swapper/2:    0] SP: 0xea1efee0:
<4>[ 2142.886932]  [2:      swapper/2:    0] [c2] fee0  f1cfff68 ebd972f8
ebd97300 c0053d04 00000000 00000000 ffffffff 00000000
<4>[ 2142.886962]  [2:      swapper/2:    0] [c2] ff00  00000002 00000000
200f0193 ffffffff ea1eff4c c000e478 200f0193 000f4240
<4>[ 2142.886993]  [2:      swapper/2:    0] [c2] ff20  00000f23 00000000
00000000 00000002 eca08dcc 000001f2 00000000 00000000
<4>[ 2142.887023]  [2:      swapper/2:    0] [c2] ff40  c0a2a3e8 00000002
003b207c ea1eff60 c00275cc 00000000 200f0193 ffffffff
<4>[ 2142.887054]  [2:      swapper/2:    0] [c2] ff60  ecdbb160 000001f2
000001dd 00000002 00000000 00000f23 ea1ee000 c156c758
<4>[ 2142.887054]  [2:      swapper/2:    0] [c2] ff80  c0a2a3e8 eca08dcc
000001f2 c04524fc eca08dcc 000001f2 00000000 00000001
<4>[ 2142.887084]  [2:      swapper/2:    0] [c2] ffa0  c156c758 00000000
ea1ee000 ea1ee000 c0a411ec 00000000 c0a2a3e8 c0452708
<4>[ 2142.887115]  [2:      swapper/2:    0] [c2] ffc0  00049290 ea1ee000
ea1ee000 ea1ee030 c0a4358c 8000406a 410fc075 00000000
<4>[ 2142.887145]  [2:      swapper/2:    0] [c2] 
<4>[ 2142.887145]  [2:      swapper/2:    0] R6: 0xeca08d4c:
<4>[ 2142.887176]  [2:      swapper/2:    0] [c2] 8d4c  00000001 0000000c
00000000 00000000 00000000 00000000 00000000 00000000
<4>[ 2142.887207]  [2:      swapper/2:    0] [c2] 8d6c  00101110 00000040
00000011 00000000 709f0002 ffff508e 00000029 00000354
<4>[ 2142.887207]  [2:      swapper/2:    0] [c2] 8d8c  0000000f 00000001
0000000b b7466d00 b72ee920 b757dc78 b2bb5ded b73466b8
<4>[ 2142.887237]  [2:      swapper/2:    0] [c2] 8dac  00000031 00000000
906f0002 0000604e 603f0000 603f603f 603f603f 603f603f
<4>[ 2142.887268]  [2:      swapper/2:    0] [c2] 8dcc  603f603f 603f603f
00000000 00000030 00000089 b7172c50 00000000 b73f32c0
<4>[ 2142.887298]  [2:      swapper/2:    0] [c2] 8dec  00000000 00000000
00000000 00000000 b731bc18 000000ce 00000000 00000007
<4>[ 2142.887329]  [2:      swapper/2:    0] [c2] 8e0c  0000000f 00000000
00000000 00000000 3fd9c000 00000000 00000000 00000000
<4>[ 2142.887359]  [2:      swapper/2:    0] [c2] 8e2c  3fdaa000 00000000
3f9e0000 00000001 00000000 00000000 00000000 00000000
<4>[ 2142.887359]  [2:      swapper/2:    0] [c2] 
<4>[ 2142.887359]  [2:      swapper/2:    0] R10: 0xc0a2a368:
<4>[ 2142.887390]  [2:      swapper/2:    0] [c2] a368  00000000 00000000
00000000 00000000 00000000 00000000 00124f80 00118c30
<4>[ 2142.887420]  [2:      swapper/2:    0] [c2] a388  0010c8e0 0010c8e0
000f4240 00000000 00000000 00000000 00000000 00000000
<4>[ 2142.887451]  [2:      swapper/2:    0] [c2] a3a8  00000001 00040004
c0a2a3b0 c0a2a3b0 00000000 00000000 c0a24194 00000000
<4>[ 2142.887481]  [2:      swapper/2:    0] [c2] a3c8  00000002 00000005
00000000 d530d530 c0a2a3d8 c0a2a3d8 c0a0a62c 00000001
<4>[ 2142.887481]  [2:      swapper/2:    0] [c2] a3e8  c08e0456 00000000
00000000 00000000 00003143 00000000 00000000 00000000
<4>[ 2142.887512]  [2:      swapper/2:    0] [c2] a408  6e617473 00796264
00000000 00000000 00000000 00000000 00000000 00000000
<4>[ 2142.887542]  [2:      swapper/2:    0] [c2] a428  00000001 00000001
00000000 00000001 00000000 c04b5a2c 00000000 00003243
<4>[ 2142.887573]  [2:      swapper/2:    0] [c2] a448  00000000 00000000
00000000 6c735f6c 00706565 00000000 00000000 00000000
<0>[ 2142.887603]  [2:      swapper/2:    0] [c2] Process swapper/2 (pid: 0,
stack limit = 0xea1ee238)
<0>[ 2142.887603]  [2:      swapper/2:    0] [c2] Stack: (0xea1eff60 to
0xea1f0000)
<0>[ 2142.887634]  [2:      swapper/2:    0] [c2] ff60: ecdbb160 000001f2
000001dd 00000002 00000000 00000f23 ea1ee000 c156c758
<0>[ 2142.887664]  [2:      swapper/2:    0] [c2] ff80: c0a2a3e8 eca08dcc
000001f2 c04524fc eca08dcc 000001f2 00000000 00000001
<0>[ 2142.887664]  [2:      swapper/2:    0] [c2] ffa0: c156c758 00000000
ea1ee000 ea1ee000 c0a411ec 00000000 c0a2a3e8 c0452708
<0>[ 2142.887695]  [2:      swapper/2:    0] [c2] ffc0: 00049290 ea1ee000
ea1ee000 ea1ee030 c0a4358c 8000406a 410fc075 00000000
<0>[ 2142.887725]  [2:      swapper/2:    0] [c2] ffe0: 00000000 c000f4ec
ea1ee000 c005eab4 c0a4358c 8069ac44 fffffefd 5577dfff
<4>[ 2142.887725]  [2:      swapper/2:    0] [c2] [<c00275cc>]
(ns_to_timeval+0x1c/0x34) from [<00000002>] (0x2)
<0>[ 2142.887756]  [2:      swapper/2:    0] [c2] Code: bad PC value
<4>[ 2142.887756]  [2:      swapper/2:    0] [c2] ---[ end trace
69cf41cae374fe59 ]---



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
