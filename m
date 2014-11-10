Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C9A5C28000D
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 10:24:57 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so8416623pab.18
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 07:24:57 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id fr3si16828748pbd.34.2014.11.10.07.24.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 10 Nov 2014 07:24:55 -0800 (PST)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NET002A8XHGW460@mailout4.samsung.com> for linux-mm@kvack.org;
 Tue, 11 Nov 2014 00:24:52 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
Subject: [bug]: Kernel panic in 3.10.17
Date: Mon, 10 Nov 2014 20:54:58 +0530
Message-id: <036d01cffcfa$8114eed0$833ecc70$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com
Cc: cpgs@samsung.com, rohit.kr@samsung.com, vishnu.ps@samsung.com

Hi,

Today, I got came across the below kernel panic, when device was idle.
As per the analysis the crash is happening in: sched/fair.c: tg_load_down: load
= tg->parent->cfs_rq[cpu]->h_load;
The backtrace says: tg->parent = 0x0, which is strange.

If anybody knows about any fixes for this, please let us know.

System Details:
ARM Cortex A7, Dual Core
Linux: 3.10.17
DDR2: 512MB

<6>[  345.074441]  [1:   kworker/u4:1:   21] [c1] PM: suspend exit 2014-11-10
05:21:14.310872543 UTC
<6>[  345.074489]  [1:   kworker/u4:1:   21] [c1] marker: 1: t:114/10/10/5/21/14
b:2/63
<1>[  345.078566] I[1:systemd-journal:  167] [c1] Unable to handle kernel NULL
pointer dereference at virtual address 00000056
<1>[  345.078626] I[1:systemd-journal:  167] [c1] pgd = dc8c4000
<1>[  345.078651] I[1:systemd-journal:  167] [c1] [00000056] *pgd=9c86e831,
*pte=00000000, *ppte=00000000
<0>[  345.078705] I[1:systemd-journal:  167] [c1] Internal error: Oops: 17 [#1]
PREEMPT SMP ARM
<4>[  345.078735] I[1:systemd-journal:  167] [c1] Modules linked in:
<4>[  345.078775] I[1:systemd-journal:  167] [c1] CPU: 1 PID: 167 Comm:
systemd-journal Tainted: G        W    3.10.17 #1-Tizen
<4>[  345.078804] I[1:systemd-journal:  167] [c1] task: dcf70cc0 ti: dce98000
task.ti: dce98000
<4>[  345.078863] I[1:systemd-journal:  167] [c1] PC is at
tg_load_down+0x30/0x74
<4>[  345.078908] I[1:systemd-journal:  167] [c1] LR is at
walk_tg_tree_from+0x34/0xbc
<4>[  345.078940] I[1:systemd-journal:  167] [c1] pc : [<c005891c>]    lr :
[<c0053910>]    psr: 20000113
<4>[  345.078940] I[1:systemd-journal:  167] sp : dce99d28  ip : d18fc07c  fp :
dce99d5c
<4>[  345.078977] I[1:systemd-journal:  167] [c1] r10: 00000000  r9 : c1184180
r8 : 00000000
<4>[  345.079003] I[1:systemd-journal:  167] [c1] r7 : c0a9ff54  r6 : c00507a0
r5 : c0a9ff54  r4 : 00000000
<4>[  345.079028] I[1:systemd-journal:  167] [c1] r3 : 0000002e  r2 : c0a9ff54
r1 : 00000000  r0 : c0a9ff54
<4>[  345.079059] I[1:systemd-journal:  167] [c1] Flags: nzCv  IRQs on  FIQs on
Mode SVC_32  ISA ARM  Segment user
<4>[  345.079086] I[1:systemd-journal:  167] [c1] Control: 10c53c7d  Table:
9c8c406a  DAC: 00000015
<4>[  345.079110] I[1:systemd-journal:  167] [c1] 
<4>[  345.079110] I[1:systemd-journal:  167] PC: 0xc005889c:
<4>[  345.079142] I[1:systemd-journal:  167] [c1] 889c  e080300c e1530001
a3a00000 b3a00001 e3510000 d3a00000 e3500000 e592002c
<4>[  345.079185] I[1:systemd-journal:  167] [c1] 88bc  0a000001 e0000390
eb06cd0d e5963000 e3500001 e5966120 93a00002 e0630000
<4>[  345.079225] I[1:systemd-journal:  167] [c1] 88dc  e3a03000 e3560000
1affffe3 e8bd8070 e92d4038 e1a05000 e59030a8 e1a04001
<4>[  345.079266] I[1:systemd-journal:  167] [c1] 88fc  e3530000 1a000005
e59f204c e59f304c e7922101 e0833002 e5930030 ea000009
<4>[  345.079305] I[1:systemd-journal:  167] [c1] 891c  e5933028 e7933101
e5901024 e5932080 e7911104 e5910000 e5931000 e0000290
<4>[  345.079345] I[1:systemd-journal:  167] [c1] 893c  e2811001 eb06ccee
e5953028 e7933104 e5830080 e3a00000 e8bd8038 c09e2840
<4>[  345.079385] I[1:systemd-journal:  167] [c1] 895c  c095f180 e3510000
e1a0c000 e92d4030 1a000006 e1c026d0 e1920003 0a000002
<4>[  345.079424] I[1:systemd-journal:  167] [c1] 897c  e59c3000 e3530c01
1a000020 e3a01001 e59c21ac e3510000 e59c3004 e5920028
<4>[  345.079468] I[1:systemd-journal:  167] [c1] 
<4>[  345.079468] I[1:systemd-journal:  167] LR: 0xc0053890:
<4>[  345.079501] I[1:systemd-journal:  167] [c1] 3890  e1a0400a e1510005
851b7028 91a06001 8087600c e24c7001 e1a0c08c e0256597
<4>[  345.079542] I[1:systemd-journal:  167] [c1] 38b0  e1a05335 e2833001
e3530005 e584500c e2844004 1affffdc e24bd020 e8bd4ff0
<4>[  345.079584] I[1:systemd-journal:  167] [c1] 38d0  eaffffad c063a1c4
c063a1c9 e92d4df0 e28db01c e24dd008 e1a04000 e1a05001
<4>[  345.079625] I[1:systemd-journal:  167] [c1] 38f0  e1a06002 e1a0a003
e1a07000 ea000000 e1a07002 e1a00007 e1a0100a e12fff35
<4>[  345.079666] I[1:systemd-journal:  167] [c1] 3910  e2508000 1a00001c
e59730b4 e50b3020 e51b2020 e24220ac ea000004 e59720ac
<4>[  345.079706] I[1:systemd-journal:  167] [c1] 3930  e1a07003 e50b2020
e51b2020 e24220ac e28210ac e28730b4 e1510003 1affffeb
<4>[  345.079749] I[1:systemd-journal:  167] [c1] 3950  e1a00007 e1a0100a
e12fff36 e0642007 e2723000 e0a33002 e3500000 13833001
<4>[  345.079790] I[1:systemd-journal:  167] [c1] 3970  e3530000 1a000003
e59730a8 e3530000 1affffe9 ea000000 e1a08000 e1a00008
<4>[  345.079835] I[1:systemd-journal:  167] [c1] 
<4>[  345.079835] I[1:systemd-journal:  167] SP: 0xdce99ca8:
<4>[  345.079868] I[1:systemd-journal:  167] [c1] 9ca8  00000009 0000268e
0000268e dce99df4 c095f180 c095f180 00000000 dd3f8950
<4>[  345.079908] I[1:systemd-journal:  167] [c1] 9cc8  00000000 c005891c
20000113 ffffffff dce99d14 c000eb58 c0a9ff54 00000000
<4>[  345.079947] I[1:systemd-journal:  167] [c1] 9ce8  c0a9ff54 0000002e
00000000 c0a9ff54 c00507a0 c0a9ff54 00000000 c1184180
<4>[  345.079987] I[1:systemd-journal:  167] [c1] 9d08  00000000 dce99d5c
d18fc07c dce99d28 c0053910 c005891c 20000113 ffffffff
<4>[  345.080026] I[1:systemd-journal:  167] [c1] 9d28  c0aa3ac4 c0aa3a10
c00588ec c0053910 0000a8ba c0aa0000 00000000 dd3f8940
<4>[  345.080066] I[1:systemd-journal:  167] [c1] 9d48  c1184180 00005610
c09e23bc 00000002 dd3f8950 c005e414 d18fc000 00000001
<4>[  345.080103] I[1:systemd-journal:  167] [c1] 9d68  c118a960 c095f180
00000000 00000000 d18fc07c 00000001 d18fc000 c1184180
<4>[  345.080141] I[1:systemd-journal:  167] [c1] 9d88  00000000 00000001
c118d180 dd3f86d0 00000000 00000001 00000fd1 c118a960
<4>[  345.080181] I[1:systemd-journal:  167] [c1] 
<4>[  345.080181] I[1:systemd-journal:  167] IP: 0xd18fbffc:
<4>[  345.080214] I[1:systemd-journal:  167] [c1] bffc  00000000 00000000
00000000 dd3f86c0 00000001 00000004 00000040 0000007d
<4>[  345.080256] I[1:systemd-journal:  167] [c1] c01c  00000001 00000002
00000000 00000000 00000000 00000000 00000000 00000000
<4>[  345.080292] I[1:systemd-journal:  167] [c1] c03c  0000022f 00000000
00001195 00000001 00000000 00000000 00000000 00000001
<4>[  345.080353] I[1:systemd-journal:  167] [c1] c05c  00000001 0000000c
00000000 00000000 00000002 00000001 00000000 00000008
<4>[  345.080414] I[1:systemd-journal:  167] [c1] c07c  00000000 00000fd1
00004225 00000000 00000000 00000002 00000000 00000000
<4>[  345.080459] I[1:systemd-journal:  167] [c1] c09c  00000000 00000001
00000000 00000008 00000000 00000000 00000000 00000000
<4>[  345.080500] I[1:systemd-journal:  167] [c1] c0bc  00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
<4>[  345.080545] I[1:systemd-journal:  167] [c1] c0dc  00000078 0000000b
00000000 c08270af c09f066c 00000000 00000002 00000003
<4>[  345.080595] I[1:systemd-journal:  167] [c1] 
<4>[  345.080595] I[1:systemd-journal:  167] FP: 0xdce99cdc:
<4>[  345.080629] I[1:systemd-journal:  167] [c1] 9cdc  c000eb58 c0a9ff54
00000000 c0a9ff54 0000002e 00000000 c0a9ff54 c00507a0
<4>[  345.080681] I[1:systemd-journal:  167] [c1] 9cfc  c0a9ff54 00000000
c1184180 00000000 dce99d5c d18fc07c dce99d28 c0053910
<4>[  345.080737] I[1:systemd-journal:  167] [c1] 9d1c  c005891c 20000113
ffffffff c0aa3ac4 c0aa3a10 c00588ec c0053910 0000a8ba
<4>[  345.080803] I[1:systemd-journal:  167] [c1] 9d3c  c0aa0000 00000000
dd3f8940 c1184180 00005610 c09e23bc 00000002 dd3f8950
<4>[  345.080857] I[1:systemd-journal:  167] [c1] 9d5c  c005e414 d18fc000
00000001 c118a960 c095f180 00000000 00000000 d18fc07c
<4>[  345.080901] I[1:systemd-journal:  167] [c1] 9d7c  00000001 d18fc000
c1184180 00000000 00000001 c118d180 dd3f86d0 00000000
<4>[  345.080959] I[1:systemd-journal:  167] [c1] 9d9c  00000001 00000fd1
c118a960 00000001 00000000 00000020 0000000a 585eee00
<4>[  345.081003] I[1:systemd-journal:  167] [c1] 9dbc  d18fc000 0000290c
00000001 00000001 dce99df4 00000000 c09c20c0 00000007
<4>[  345.081047] I[1:systemd-journal:  167] [c1] 
<4>[  345.081047] I[1:systemd-journal:  167] R0: 0xc0a9fed4:
<4>[  345.081083] I[1:systemd-journal:  167] [c1] fed4  82000000 726f776b
2f72656b 00303a30 00000000 00000004 3d203000 5d30635b
<4>[  345.081131] I[1:systemd-journal:  167] [c1] fef4  776f7020 6f647265
635f6e77 20737570 20363d69 00002121 00000000 c69760e0
<4>[  345.081181] I[1:systemd-journal:  167] [c1] ff14  0000002e 00260050
82000000 726f776b 2f72656b 00303a30 00000000 00000004
<4>[  345.081225] I[1:systemd-journal:  167] [c1] ff34  37783000 5d30635b
616c7020 726f6674 70635f6d 696b5f75 66206c6c 73696e69
<4>[  345.081265] I[1:systemd-journal:  167] [c1] ff54  20646568 20303d69
00002121 d4d17e56 0000002e 00250050 c6000000 726f776b
<4>[  345.081304] I[1:systemd-journal:  167] [c1] ff74  2f72656b 00303a30
00000000 00000004 00000000 5d30635b 53415b20 433a436f
<4>[  345.081343] I[1:systemd-journal:  167] [c1] ff94  34564344 6e69205d
20726574 53204150 63746977 664f2068 00000066 d56511c8
<4>[  345.081382] I[1:systemd-journal:  167] [c1] ffb4  0000002e 00190048
c6000000 726f776b 2f72656b 00303a30 00000000 00000004
<4>[  345.081425] I[1:systemd-journal:  167] [c1] 
<4>[  345.081425] I[1:systemd-journal:  167] R2: 0xc0a9fed4:
<4>[  345.081458] I[1:systemd-journal:  167] [c1] fed4  82000000 726f776b
2f72656b 00303a30 00000000 00000004 3d203000 5d30635b
<4>[  345.081500] I[1:systemd-journal:  167] [c1] fef4  776f7020 6f647265
635f6e77 20737570 20363d69 00002121 00000000 c69760e0
<4>[  345.081539] I[1:systemd-journal:  167] [c1] ff14  0000002e 00260050
82000000 726f776b 2f72656b 00303a30 00000000 00000004
<4>[  345.081577] I[1:systemd-journal:  167] [c1] ff34  37783000 5d30635b
616c7020 726f6674 70635f6d 696b5f75 66206c6c 73696e69
<4>[  345.081617] I[1:systemd-journal:  167] [c1] ff54  20646568 20303d69
00002121 d4d17e56 0000002e 00250050 c6000000 726f776b
<4>[  345.081658] I[1:systemd-journal:  167] [c1] ff74  2f72656b 00303a30
00000000 00000004 00000000 5d30635b 53415b20 433a436f
<4>[  345.081696] I[1:systemd-journal:  167] [c1] ff94  34564344 6e69205d
20726574 53204150 63746977 664f2068 00000066 d56511c8
<4>[  345.081752] I[1:systemd-journal:  167] [c1] ffb4  0000002e 00190048
c6000000 726f776b 2f72656b 00303a30 00000000 00000004
<4>[  345.081814] I[1:systemd-journal:  167] [c1] 
<4>[  345.081814] I[1:systemd-journal:  167] R5: 0xc0a9fed4:
<4>[  345.081848] I[1:systemd-journal:  167] [c1] fed4  82000000 726f776b
2f72656b 00303a30 00000000 00000004 3d203000 5d30635b
<4>[  345.081887] I[1:systemd-journal:  167] [c1] fef4  776f7020 6f647265
635f6e77 20737570 20363d69 00002121 00000000 c69760e0
<4>[  345.081935] I[1:systemd-journal:  167] [c1] ff14  0000002e 00260050
82000000 726f776b 2f72656b 00303a30 00000000 00000004
<4>[  345.081974] I[1:systemd-journal:  167] [c1] ff34  37783000 5d30635b
616c7020 726f6674 70635f6d 696b5f75 66206c6c 73696e69
<4>[  345.082013] I[1:systemd-journal:  167] [c1] ff54  20646568 20303d69
00002121 d4d17e56 0000002e 00250050 c6000000 726f776b
<4>[  345.082053] I[1:systemd-journal:  167] [c1] ff74  2f72656b 00303a30
00000000 00000004 00000000 5d30635b 53415b20 433a436f
<4>[  345.082092] I[1:systemd-journal:  167] [c1] ff94  34564344 6e69205d
20726574 53204150 63746977 664f2068 00000066 d56511c8
<4>[  345.082137] I[1:systemd-journal:  167] [c1] ffb4  0000002e 00190048
c6000000 726f776b 2f72656b 00303a30 00000000 00000004
<4>[  345.082180] I[1:systemd-journal:  167] [c1] 
<4>[  345.082180] I[1:systemd-journal:  167] R6: 0xc0050720:
<4>[  345.082213] I[1:systemd-journal:  167] [c1] 0720  ea17803d c09f0584
c09e2840 e92d40f8 e1a07000 e59f505c e59f605c e1a00005
<4>[  345.082257] I[1:systemd-journal:  167] [c1] 0740  eb1780cb e595401c
e2855018 e2444004 ea00000a e7962107 e5943000 e7930002
<4>[  345.082303] I[1:systemd-journal:  167] [c1] 0760  e3500000 0a000003
e5d4302c e3530000 1a000000 ebffe3f7 e5944008 e2444004
<4>[  345.082344] I[1:systemd-journal:  167] [c1] 0780  e2843004 e1530005
1afffff1 e59f0004 e8bd40f8 ea178020 c09f0584 c09e2840
<4>[  345.082383] I[1:systemd-journal:  167] [c1] 07a0  e92d4800 e3a00000
e28db004 e8bd8800 e59031b4 e5902024 e3530005 12422064
<4>[  345.082424] I[1:systemd-journal:  167] [c1] 07c0  159f3028 03a03003
05803038 059f3020 17931102 10833102 e92d4800 e28db004
<4>[  345.082467] I[1:systemd-journal:  167] [c1] 07e0  159330a0 15801038
e580303c e8bd8800 c0639f84 55555555 e3530000 e3a0cb02
<4>[  345.082509] I[1:systemd-journal:  167] [c1] 0800  e92d4800 e28db004
0a000008 e3130001 100c019c 128ccb01 11a0c5ac e1b030a3
<4>[  345.082552] I[1:systemd-journal:  167] [c1] 
<4>[  345.082552] I[1:systemd-journal:  167] R7: 0xc0a9fed4:
<4>[  345.082585] I[1:systemd-journal:  167] [c1] fed4  82000000 726f776b
2f72656b 00303a30 00000000 00000004 3d203000 5d30635b
<4>[  345.082624] I[1:systemd-journal:  167] [c1] fef4  776f7020 6f647265
635f6e77 20737570 20363d69 00002121 00000000 c69760e0
<4>[  345.082664] I[1:systemd-journal:  167] [c1] ff14  0000002e 00260050
82000000 726f776b 2f72656b 00303a30 00000000 00000004
<4>[  345.082702] I[1:systemd-journal:  167] [c1] ff34  37783000 5d30635b
616c7020 726f6674 70635f6d 696b5f75 66206c6c 73696e69
<4>[  345.082741] I[1:systemd-journal:  167] [c1] ff54  20646568 20303d69
00002121 d4d17e56 0000002e 00250050 c6000000 726f776b
<4>[  345.082780] I[1:systemd-journal:  167] [c1] ff74  2f72656b 00303a30
00000000 00000004 00000000 5d30635b 53415b20 433a436f
<4>[  345.082819] I[1:systemd-journal:  167] [c1] ff94  34564344 6e69205d
20726574 53204150 63746977 664f2068 00000066 d56511c8
<4>[  345.082857] I[1:systemd-journal:  167] [c1] ffb4  0000002e 00190048
c6000000 726f776b 2f72656b 00303a30 00000000 00000004
<4>[  345.082897] I[1:systemd-journal:  167] [c1] 
<4>[  345.082897] I[1:systemd-journal:  167] R9: 0xc1184100:
<4>[  345.082929] I[1:systemd-journal:  167] [c1] 4100  00000000 c1184104
c1184104 00000000 00000000 df8650e0 df8650e0 00000000
<4>[  345.082969] I[1:systemd-journal:  167] [c1] 4120  00000001 00000000
00000000 00000000 df83a800 00000000 00000000 00000001
<4>[  345.083006] I[1:systemd-journal:  167] [c1] 4140  00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
<4>[  345.083043] I[1:systemd-journal:  167] [c1] 4160  00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
<4>[  345.083079] I[1:systemd-journal:  167] [c1] 4180  36a936a9 0000000b
00004d1b 0000268e 0000136d 00000a44 000006c7 0000119c
<4>[  345.083118] I[1:systemd-journal:  167] [c1] 41a0  00000000 00000000
00000000 00000000 0000512a 00000000 00006320 00000000
<4>[  345.083156] I[1:systemd-journal:  167] [c1] 41c0  00058a45 00000000
0000512a 00000000 0000000b 0000000b 3e0c2cdc 00000016
<4>[  345.083195] I[1:systemd-journal:  167] [c1] 41e0  2d932272 00000093
2d932272 00000093 df868040 dcffaf00 dba7f778 00000000
<0>[  345.083247] I[1:systemd-journal:  167] [c1] Process systemd-journal (pid:
167, stack limit = 0xdce98238)
<0>[  345.083273] I[1:systemd-journal:  167] [c1] Stack: (0xdce99d28 to
0xdce9a000)
<0>[  345.083309] I[1:systemd-journal:  167] [c1] 9d20:
c0aa3ac4 c0aa3a10 c00588ec c0053910 0000a8ba c0aa0000
<0>[  345.083340] I[1:systemd-journal:  167] [c1] 9d40: 00000000 dd3f8940
c1184180 00005610 c09e23bc 00000002 dd3f8950 c005e414
<0>[  345.083372] I[1:systemd-journal:  167] [c1] 9d60: d18fc000 00000001
c118a960 c095f180 00000000 00000000 d18fc07c 00000001
<0>[  345.083404] I[1:systemd-journal:  167] [c1] 9d80: d18fc000 c1184180
00000000 00000001 c118d180 dd3f86d0 00000000 00000001
<0>[  345.083434] I[1:systemd-journal:  167] [c1] 9da0: 00000fd1 c118a960
00000001 00000000 00000020 0000000a 585eee00 d18fc000
<0>[  345.083466] I[1:systemd-journal:  167] [c1] 9dc0: 0000290c 00000001
00000001 dce99df4 00000000 c09c20c0 00000007 c005e96c
<0>[  345.083496] I[1:systemd-journal:  167] [c1] 9de0: dce99df4 c004cea8
c118d180 00000000 585eee00 00000001 c095c7b0 00000001
<0>[  345.083528] I[1:systemd-journal:  167] [c1] 9e00: 00000005 c09e2840
c095f180 dce98000 00000100 00000001 c0a46904 c005ea40
<0>[  345.083559] I[1:systemd-journal:  167] [c1] 9e20: c09c209c 00000b90
0082e000 dce98000 00000005 c09c209c 00000007 00000580
<0>[  345.083592] I[1:systemd-journal:  167] [c1] 9e40: 00000100 00000001
c0a46904 c0031f94 00000001 dce99e7c 00000000 c09c4f40
<0>[  345.083623] I[1:systemd-journal:  167] [c1] 9e60: 0000000a 00404100
0000119d 00000001 bed7a46f 60000193 00000000 c09e2a08
<0>[  345.083656] I[1:systemd-journal:  167] [c1] 9e80: dce99efc 00000580
bed7a46f 00000001 b6f89118 c00321ac dce98000 c0032418
<0>[  345.083688] I[1:systemd-journal:  167] [c1] 9ea0: 0000003d c000f8dc
0000003d e0802000 dce99ec8 c00092b8 c0630a8c a0000013
<0>[  345.083720] I[1:systemd-journal:  167] [c1] 9ec0: ffffffff c000ebc0
dcb4caa8 bed7a46f 00000000 00000000 dcb4caa8 c2c509c0
<0>[  345.083751] I[1:systemd-journal:  167] [c1] 9ee0: bed7a46f dce99f80
00000580 bed7a46f 00000001 b6f89118 dcb4caa8 dce99f10
<0>[  345.083783] I[1:systemd-journal:  167] [c1] 9f00: c010fcec c0630a8c
a0000013 ffffffff dcb4ca80 c010fcec 00000000 dce99f80
<0>[  345.083814] I[1:systemd-journal:  167] [c1] 9f20: c2c509c0 dcb4caa8
00000000 c00f3cac 00000000 00000000 b6f70000 00000001
<0>[  345.083847] I[1:systemd-journal:  167] [c1] 9f40: c2c509c0 bed7a46f
dce99f80 00000580 00000000 00000000 b6f89118 c00f416c
<0>[  345.083878] I[1:systemd-journal:  167] [c1] 9f60: c2c509c0 bed7a46f
c2c509c0 00000000 bed7a46f 00000001 00000580 c00f4308
<0>[  345.083909] I[1:systemd-journal:  167] [c1] 9f80: 00000580 00000000
00000001 00001ff7 bed7c6b4 0000000b 00000003 c000f184
<0>[  345.083938] I[1:systemd-journal:  167] [c1] 9fa0: dce98000 c000f000
00001ff7 bed7c6b4 0000000b bed7a46f 00000001 00000001
<0>[  345.083970] I[1:systemd-journal:  167] [c1] 9fc0: 00001ff7 bed7c6b4
0000000b 00000003 00000000 0000000b b6f7ff68 b6f89118
<0>[  345.084002] I[1:systemd-journal:  167] [c1] 9fe0: bed7c6ac bed7a468
b6f7fa4d b6ec9e8c 60000010 0000000b 79666974 6b203a20
<4>[  345.084097] I[1:systemd-journal:  167] [c1] [<c005891c>]
(tg_load_down+0x30/0x74) from [<c0053910>] (walk_tg_tree_from+0x34/0xbc)
<4>[  345.084144] I[1:systemd-journal:  167] [c1] [<c0053910>]
(walk_tg_tree_from+0x34/0xbc) from [<c005e414>] (load_balance+0x2a4/0x710)
<4>[  345.084182] I[1:systemd-journal:  167] [c1] [<c005e414>]
(load_balance+0x2a4/0x710) from [<c005e96c>] (rebalance_domains+0xec/0x184)
<4>[  345.084217] I[1:systemd-journal:  167] [c1] [<c005e96c>]
(rebalance_domains+0xec/0x184) from [<c005ea40>]
(run_rebalance_domains+0x3c/0x130)
<4>[  345.084269] I[1:systemd-journal:  167] [c1] [<c005ea40>]
(run_rebalance_domains+0x3c/0x130) from [<c0031f94>] (__do_softirq+0x150/0x2d4)
<4>[  345.084309] I[1:systemd-journal:  167] [c1] [<c0031f94>]
(__do_softirq+0x150/0x2d4) from [<c00321ac>] (do_softirq+0x44/0x50)
<4>[  345.084346] I[1:systemd-journal:  167] [c1] [<c00321ac>]
(do_softirq+0x44/0x50) from [<c0032418>] (irq_exit+0x74/0xbc)
<4>[  345.084390] I[1:systemd-journal:  167] [c1] [<c0032418>]
(irq_exit+0x74/0xbc) from [<c000f8dc>] (handle_IRQ+0x68/0x8c)
<4>[  345.084431] I[1:systemd-journal:  167] [c1] [<c000f8dc>]
(handle_IRQ+0x68/0x8c) from [<c00092b8>] (gic_handle_irq+0x34/0x58)
<4>[  345.084467] I[1:systemd-journal:  167] [c1] [<c00092b8>]
(gic_handle_irq+0x34/0x58) from [<c000ebc0>] (__irq_svc+0x40/0x70)
<4>[  345.084493] I[1:systemd-journal:  167] [c1] Exception stack(0xdce99ec8 to
0xdce99f10)
<4>[  345.084522] I[1:systemd-journal:  167] [c1] 9ec0:
dcb4caa8 bed7a46f 00000000 00000000 dcb4caa8 c2c509c0
<4>[  345.084554] I[1:systemd-journal:  167] [c1] 9ee0: bed7a46f dce99f80
00000580 bed7a46f 00000001 b6f89118 dcb4caa8 dce99f10
<4>[  345.084580] I[1:systemd-journal:  167] [c1] 9f00: c010fcec c0630a8c
a0000013 ffffffff
<4>[  345.084628] I[1:systemd-journal:  167] [c1] [<c000ebc0>]
(__irq_svc+0x40/0x70) from [<c0630a8c>] (mutex_lock+0x18/0x48)
<4>[  345.084684] I[1:systemd-journal:  167] [c1] [<c0630a8c>]
(mutex_lock+0x18/0x48) from [<c010fcec>] (seq_read+0x2c/0x45c)
<4>[  345.084731] I[1:systemd-journal:  167] [c1] [<c010fcec>]
(seq_read+0x2c/0x45c) from [<c00f416c>] (vfs_read+0xac/0x124)
<4>[  345.084770] I[1:systemd-journal:  167] [c1] [<c00f416c>]
(vfs_read+0xac/0x124) from [<c00f4308>] (SyS_read+0x3c/0x60)
<4>[  345.084804] I[1:systemd-journal:  167] [c1] [<c00f4308>]
(SyS_read+0x3c/0x60) from [<c000f000>] (ret_fast_syscall+0x0/0x30)
<0>[  345.084837] I[1:systemd-journal:  167] [c1] Code: e7922101 e0833002
e5930030 ea000009 (e5933028) 
<4>[  345.084887] I[1:systemd-journal:  167] [c1] ---[ end trace
1b75b31a2719ed1f ]---
<0>[  345.084919] I[1:systemd-journal:  167] [c1] Kernel panic - not syncing:
Fatal exception in interrupt



Thanks,
Pintu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
