Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A24A86B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 15:26:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b23so968899wme.3
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 12:26:22 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id l19-v6si8415719wrl.235.2018.04.24.12.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 12:26:20 -0700 (PDT)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 40Vtbv026Wz9ttS3
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 21:26:19 +0200 (CEST)
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id xTURzAwTD2uo for <linux-mm@kvack.org>;
	Tue, 24 Apr 2018 21:26:18 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 40Vtbt6PyHz9ttFv
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 21:26:18 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 6180F8B90E
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 21:26:20 +0200 (CEST)
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id Mu-uxQp32wNx for <linux-mm@kvack.org>;
	Tue, 24 Apr 2018 21:26:20 +0200 (CEST)
Received: from [192.168.232.53] (unknown [192.168.232.53])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 032D68B902
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 21:26:19 +0200 (CEST)
From: christophe leroy <christophe.leroy@c-s.fr>
Subject: OOM killer invoked while still one forth of mem is available
Message-ID: <df1a8c14-bda3-6271-d403-24b88a254b2c@c-s.fr>
Date: Tue, 24 Apr 2018 21:26:17 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi

Allthough there is still about one forth of memory available (7976kB 
among 32MB), oom-killer is invoked and makes a victim.

What could be the reason and how could it be solved ?

[   54.400754] S99watchdogd-ap invoked oom-killer: 
gfp_mask=3D0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), nodemask=3D0, 
order=3D1, oom_score_adj=3D0
[   54.400815] CPU: 0 PID: 777 Comm: S99watchdogd-ap Not tainted 
4.9.85-local-knld-998 #5
[   54.400830] Call Trace:
[   54.400910] [c1ca5d10] [c0327d28] dump_header.isra.4+0x54/0x17c 
(unreliable)
[   54.400998] [c1ca5d50] [c0079d88] oom_kill_process+0xc4/0x414
[   54.401067] [c1ca5d90] [c007a5c8] out_of_memory+0x35c/0x37c
[   54.401220] [c1ca5dc0] [c007d68c] __alloc_pages_nodemask+0x8ec/0x9a8
[   54.401318] [c1ca5e70] [c00169d4] copy_process.isra.9.part.10+0xdc/0x10d=
0
[   54.401398] [c1ca5f00] [c0017b30] _do_fork+0xcc/0x2a8
[   54.401473] [c1ca5f40] [c000a660] ret_from_syscall+0x0/0x38
[   54.401501] Mem-Info:
[   54.401616] active_anon:2727 inactive_anon:91 isolated_anon:0
[   54.401616]  active_file:51 inactive_file:26 isolated_file:0
[   54.401616]  unevictable:604 dirty:0 writeback:0 unstable:0
[   54.401616]  slab_reclaimable:115 slab_unreclaimable:722
[   54.401616]  mapped:787 shmem:284 pagetables:167 bounce:0
[   54.401616]  free:1994 free_pcp:0 free_cma:0
[   54.401715] Node 0 active_anon:10908kB inactive_anon:364kB 
active_file:204kB inactive_file:104kB unevictable:2416kB 
isolated(anon):0kB isolated(file):0kB mapped:3148kB dirty:0kB 
writeback:0kB shmem:1136kB writeback_tmp:0kB unstable:0kB 
pages_scanned:59 all_unreclaimable? no
[   54.401851] DMA free:7976kB min:660kB low:824kB high:988kB 
active_anon:10908kB inactive_anon:364kB active_file:204kB 
inactive_file:104kB unevictable:2416kB writepending:0kB present:32768kB 
managed:27912kB mlocked:2416kB slab_reclaimable:460kB 
slab_unreclaimable:2888kB kernel_stack:880kB pagetables:668kB bounce:0kB 
free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 0 0
[   54.437414] DMA: 460*4kB (UH) 201*8kB (UH) 121*16kB (UH) 43*32kB (UH) 
10*64kB (U) 4*128kB (UH) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 
0*8192kB =3D 7912kB
[   54.437730] Node 0 hugepages_total=3D0 hugepages_free=3D0 
hugepages_surp=3D0 hugepages_size=3D512kB
[   54.437768] Node 0 hugepages_total=3D0 hugepages_free=3D0 
hugepages_surp=3D0 hugepages_size=3D8192kB
[   54.437784] 892 total pagecache pages
[   54.437802] 8192 pages RAM
[   54.437818] 0 pages HighMem/MovableOnly
[   54.437834] 1214 pages reserved
[   54.437854] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds 
swapents oom_score_adj name
[   54.437928] [  216]     0   216     1240      253       6       0 
    0             0 rcS
[   54.437986] [  356]     0   356     4687      333       7       0 
    0             0 rsyslogd
[   54.438042] [  360]     0   360     1240      245       5       0 
    0             0 klogd
[   54.438099] [  370]     0   370      701      607       5       0 
    0         -1000 watchdog
[   54.438156] [  384]     0   384     1114      440       5       0 
    0             0 ntpd
[   54.438213] [  401]     0   401     1279      419       6       0 
    0             0 inetd
[   54.438270] [  413]     0   413     1240      330       6       0 
    0             0 crond
[   54.438328] [  587]     0   587     3334      586       7       0 
    0             0 CORSurv
[   54.438384] [  614]     0   614      484      232       5       0 
    0             0 ASMcsci
[   54.438441] [  662]     0   662    18777      625      13       0 
    0             0 VOIPcsc
[   54.438499] [  708]     0   708    18402     1166      22       0 
    0             0 RCUSwitch
[   54.447253] [  739]     0   739    12958     1275      17       0 
    0             0 CRI_main
[   54.447320] [  756]     0   756     1240      380       6       0 
    0             0 exe
[   54.447379] [  757]     0   757     1240      369       6       0 
    0             0 S99watchdogd-ap
[   54.447436] [  777]     0   777     1240      210       5       0 
    0             0 S99watchdogd-ap
[   54.447493] [  782]     0   782      793      425       5       0 
    0             0 socat
[   54.447550] [  784]     0   784      754      420       5       0 
    0             0 socat
[   54.447607] [  791]     0   791      793      426       5       0 
    0             0 socat
[   54.447663] [  792]     0   792      754      420       5       0 
    0             0 socat
[   54.447720] [  799]     0   799      793      426       5       0 
    0             0 socat
[   54.447777] [  800]     0   800      754      420       5       0 
    0             0 socat
[   54.447833] [  807]     0   807      793      425       5       0 
    0             0 socat
[   54.447890] [  808]     0   808      754      421       5       0 
    0             0 socat
[   54.447927] Out of memory: Kill process 739 (CRI_main) score 180 or 
sacrifice child
[   54.528280] Killed process 739 (CRI_main) total-vm:51832kB, 
anon-rss:3140kB, file-rss:1592kB, shmem-rss:236kB

Thanks
Christophe

---
L'absence de virus dans ce courrier =C3=A9lectronique a =C3=A9t=C3=A9 v=C3=
=A9rifi=C3=A9e par le logiciel antivirus Avast.
https://www.avast.com/antivirus
