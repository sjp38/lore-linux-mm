Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 944006B0256
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 04:59:55 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id p65so63768063wmp.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 01:59:55 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id gb10si18151514wjb.133.2016.03.07.01.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 01:59:54 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id l68so63656254wml.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 01:59:54 -0800 (PST)
From: Holger Schurig <holgerschurig@gmail.com>
Subject: Re: 4.4.3: OOPS when running "stress-ng --sock 5"
In-Reply-To: <87twkmd6or.fsf@gmail.com> (Holger Schurig's message of "Fri, 04
	Mar 2016 08:48:52 +0100")
References: <87twkmd6or.fsf@gmail.com>
Date: Mon, 07 Mar 2016 10:59:51 +0100
Message-ID: <87bn6qd2w8.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

I have rejoiced prematurely, it just now took way longer I hit the
segfault. Previously 1m or at max 2m was enough.

root@ptxc:~# stress-ng --sock 20
stress-ng: info: [359] dispatching hogs: 0 I/O-Sync, 0 CPU, 0 VM-mmap, 0 HDD-Write, 0 Fork, 0 Context-switch, 0 Pipe, 0 Cache, 20 Socket, 0 Yield, 0 Fallocate, 0 Flock, 0 Affinity, 0 Timer, 0 Dentry, 0 Urandom, 0 Float, 0 Int, 0 Semaphore, 0 Open, 0 SigQueue, 0 Poll
[   42.253392] random: nonblocking pool is initialized
[  567.649965] Unable to handle kernel NULL pointer dereference at virtual address 00000104
[  567.658087] pgd = ee11c000
[  567.660797] [00000104] *pgd=3eaf4831, *pte=00000000, *ppte=00000000
[  567.667112] Internal error: Oops: 817 [#1] SMP ARM
[  567.671904] Modules linked in: bnep btusb btrtl btbcm btintel bluetooth smsc95xx usbnet usbhid mii imx_sdma flexcan
[  567.682514] CPU: 1 PID: 383 Comm: stress-ng-socke Not tainted 4.4.4PTXC #3
[  567.689390] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
[  567.695920] task: ed9f9e00 ti: eeaf0000 task.ti: eeaf0000
[  567.701333] PC is at __rmqueue+0x74/0x308
[  567.705346] LR is at 0x3
[  567.707882] pc : [<c00973cc>]    lr : [<00000003>]    psr: 60030093
[  567.707882] sp : eeaf1c00  ip : 00000200  fp : eeaf1c4c
[  567.719359] r10: efd5f514  r9 : 00000008  r8 : 00000000
[  567.724585] r7 : 00000003  r6 : 00000000  r5 : c051343c  r4 : 00000100
[  567.731113] r3 : c05d6e2c  r2 : 0000006c  r1 : 00000200  r0 : 00000100
[  567.737643] Flags: nZCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment none
[  567.744866] Control: 10c5387d  Table: 3e11c04a  DAC: 00000051
[  567.750612] Process stress-ng-socke (pid: 383, stack limit = 0xeeaf0210)
[  567.757314] Stack: (0xeeaf1c00 to 0xeeaf2000)
[  567.761677] 1c00: 0000ffff c05d3200 ed976880 ed976880 eeaf1c54 c05d6d40 c03dc720 c03da9e8
[  567.769859] 1c20: 20030013 eeaf1d54 c051343c c0513428 c0513428 6104de4b 00000008 c05d6d40
[  567.778040] 1c40: eeaf1ce4 eeaf1c50 c0097d84 c0097364 00000141 0002a602 ef7bc2c0 00000018
[  567.786220] 1c60: c05d77c0 c05d77c0 00000000 c05d6d40 00000000 00000000 00000000 00000000
[  567.794401] 1c80: 00000100 c05d6f50 c05d77c8 c05d6e68 c05d78d5 00000128 00000141 020252c0
[  567.802582] 1ca0: 00000000 fffffff8 00000000 eeaf1d54 60030013 00000003 00000000 020052c0
[  567.810762] 1cc0: 00000003 c05d77c0 0000ffcb 6104de4b eeaf1e84 00000000 eeaf1d9c eeaf1ce8
[  567.818942] 1ce0: c0098154 c009766c c006cb38 00100010 60ecb9db 40030013 eeaf1d1c ed976880
[  567.827123] 1d00: ed976880 00040000 eacecc00 ed976880 eeaf1d84 eeaf1d20 c03f4d44 c03f2c30
[  567.835304] 1d20: 00000002 ef001c00 00000000 024102c0 00000000 000346db c05b8100 00000000
[  567.843484] 1d40: 00000002 ed976c14 00000002 00000000 00000000 c05d77c0 00000000 c05d6d40
[  567.851664] 1d60: 00000000 00000000 00000000 00000000 eeaf1e84 ed9fa2b4 024000c0 00000fb0
[  567.859845] 1d80: 0000ffcb 6104de4b eeaf1e84 00000000 eeaf1db4 eeaf1da0 c03901d4 c0098088
[  567.868025] 1da0: ed976880 ed976880 eeaf1dcc eeaf1db8 c039024c c0390170 eaf60600 ed976880
[  567.876206] 1dc0: eeaf1e4c eeaf1dd0 c03e83fc c039023c 0000ffcb 00000001 23c09b2d 000017c8
[  567.884386] 1de0: 00000001 eeaf1e8c c05b8bb4 eeaf0000 00000001 00000000 ed9fa2b4 00000000
[  567.892566] 1e00: 00000001 ed976938 0000ffcb 00000c90 c004c6d8 0000ffcb 7fffffff c00473e8
[  567.900747] 1e20: ed983c80 ed976880 00000000 00000000 00000000 eea03780 eeaf0000 00000000
[  567.908927] 1e40: eeaf1e6c eeaf1e50 c040ec5c c03e8228 00000000 00000000 eeaf1eec 00000000
[  567.917107] 1e60: eeaf1e7c eeaf1e70 c038c308 c040ebd4 eeaf1ed4 eeaf1e80 c038c3a4 c038c2f8
[  567.925287] 1e80: c0050004 00000000 00000000 00000001 00000c90 00000fb0 eeaf1ee4 00000001
[  567.933467] 1ea0: 00000000 00000000 00000000 eeaf1f00 afb50401 eea03780 eeaf1f80 00000000
[  567.941647] 1ec0: 00000000 c000fae4 eeaf1f3c eeaf1ed8 c00cfe84 c038c324 00001c40 ef0a4000
[  567.949828] 1ee0: eeaf1f14 bef469bc 00001c40 00000001 00000000 00001c40 eeaf1ee4 00000001
[  567.958008] 1f00: eea03780 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[  567.966189] 1f20: eea03780 00001c40 bef469bc eeaf1f80 eeaf1f4c eeaf1f40 c00cfedc c00cfe08
[  567.974369] 1f40: eeaf1f7c eeaf1f50 c00d0688 c00cfeb4 00000000 00000000 eeaf1f7c eea03780
[  567.982550] 1f60: eea03780 00001c40 bef469bc c000fae4 eeaf1fa4 eeaf1f80 c00d0f64 c00d05fc
[  567.990730] 1f80: 00000000 00000000 00000004 0002a1e8 b6f94598 00000004 00000000 eeaf1fa8
[  567.998910] 1fa0: c000f920 c00d0f24 00000004 0002a1e8 00000004 bef469bc 00001c40 bef489bc
[  568.007091] 1fc0: 00000004 0002a1e8 b6f94598 00000004 00001c40 0000018d 0002a1f0 00000003
[  568.015271] 1fe0: 00000000 bef468f4 00014a57 b6ecf4d6 40030030 00000004 00000000 00000000
[  568.023447] Backtrace: 
[  568.025916] [<c0097358>] (__rmqueue) from [<c0097d84>] (get_page_from_freelist+0x724/0x914)
[  568.034267]  r10:c05d6d40 r9:00000008 r8:6104de4b r7:c0513428 r6:c0513428 r5:c051343c
[  568.042164]  r4:eeaf1d54
[  568.044716] [<c0097660>] (get_page_from_freelist) from [<c0098154>] (__alloc_pages_nodemask+0xd8/0x898)
[  568.054108]  r10:00000000 r9:eeaf1e84 r8:6104de4b r7:0000ffcb r6:c05d77c0 r5:00000003
[  568.062004]  r4:020052c0
[  568.064566] [<c009807c>] (__alloc_pages_nodemask) from [<c03901d4>] (skb_page_frag_refill+0x70/0xcc)
[  568.073697]  r10:00000000 r9:eeaf1e84 r8:6104de4b r7:0000ffcb r6:00000fb0 r5:024000c0
[  568.081593]  r4:ed9fa2b4
[  568.084145] [<c0390164>] (skb_page_frag_refill) from [<c039024c>] (sk_page_frag_refill+0x1c/0x74)
[  568.093016]  r5:ed976880 r4:ed976880
[  568.096627] [<c0390230>] (sk_page_frag_refill) from [<c03e83fc>] (tcp_sendmsg+0x1e0/0xa68)
[  568.104890]  r5:ed976880 r4:eaf60600
[  568.108507] [<c03e821c>] (tcp_sendmsg) from [<c040ec5c>] (inet_sendmsg+0x94/0xc8)
[  568.115989]  r10:00000000 r9:eeaf0000 r8:eea03780 r7:00000000 r6:00000000 r5:00000000
[  568.123884]  r4:ed976880
[  568.126436] [<c040ebc8>] (inet_sendmsg) from [<c038c308>] (sock_sendmsg+0x1c/0x2c)
[  568.134004]  r5:00000000 r4:eeaf1eec
[  568.137610] [<c038c2ec>] (sock_sendmsg) from [<c038c3a4>] (sock_write_iter+0x8c/0xc0)
[  568.145448] [<c038c318>] (sock_write_iter) from [<c00cfe84>] (new_sync_write+0x88/0xac)
[  568.153450]  r8:c000fae4 r7:00000000 r6:00000000 r5:eeaf1f80 r4:eea03780
[  568.160221] [<c00cfdfc>] (new_sync_write) from [<c00cfedc>] (__vfs_write+0x34/0x40)
[  568.167877]  r7:eeaf1f80 r6:bef469bc r5:00001c40 r4:eea03780
[  568.173592] [<c00cfea8>] (__vfs_write) from [<c00d0688>] (vfs_write+0x98/0x16c)
[  568.180905] [<c00d05f0>] (vfs_write) from [<c00d0f64>] (SyS_write+0x4c/0xa8)
[  568.187953]  r8:c000fae4 r7:bef469bc r6:00001c40 r5:eea03780 r4:eea03780
[  568.194730] [<c00d0f18>] (SyS_write) from [<c000f920>] (ret_fast_syscall+0x0/0x3c)
[  568.202299]  r7:00000004 r6:b6f94598 r5:0002a1e8 r4:00000004
[  568.208014] Code: e3a04c01 e157000e e1a02102 e3a0cc02 (e5801004) 
[  568.214113] ---[ end trace a72ad5170492b3b2 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
