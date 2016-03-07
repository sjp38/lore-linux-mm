Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 40DE36B0254
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 06:20:08 -0500 (EST)
Received: by mail-lb0-f171.google.com with SMTP id xr8so29621814lbb.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 03:20:08 -0800 (PST)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id pn3si2813013lbb.30.2016.03.07.03.20.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Mar 2016 03:20:06 -0800 (PST)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1actCn-0007jz-HU
	for linux-mm@kvack.org; Mon, 07 Mar 2016 12:20:05 +0100
Received: from 92.243.181.209 ([92.243.181.209])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 12:20:05 +0100
Received: from matwey.kornilov by 92.243.181.209 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 12:20:05 +0100
From: "Matwey V. Kornilov" <matwey.kornilov@gmail.com>
Subject: 4.5.0-rc6: kernel BUG at ../mm/memory.c:1879
Date: Mon, 7 Mar 2016 14:14:14 +0300
Message-ID: <nbjnq6$fim$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Hello,

I see the following when try to boot 4.5.0-rc6 on ARM TI AM33xx based board.

    [   13.907631] ------------[ cut here ]------------
    [   13.912323] kernel BUG at ../mm/memory.c:1879!
    [   13.916795] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
    [   13.922663] Modules linked in:
    [   13.925761] CPU: 0 PID: 242 Comm: systemd-udevd Not tainted 4.5.0-rc6-3.ga55dde2-default #1
    [   13.934153] Hardware name: Generic AM33XX (Flattened Device Tree)
    [   13.940281] task: c2da2040 ti: c2db4000 task.ti: c2db4000
    [   13.945738] PC is at apply_to_page_range+0x23c/0x240
    [   13.950741] LR is at change_memory_common+0x94/0xe0
    [   13.955648] pc : [<c03b333c>]    lr : [<c0231dc4>]    psr: 60010013
    [   13.955648] sp : c2db5d88  ip : c2db5dd8  fp : c2db5dd4
    [   13.967182] r10: bf002080  r9 : c2db5de8  r8 : c0231cec
    [   13.972434] r7 : bf002180  r6 : bf006000  r5 : bf006000  r4 : bf006000
    [   13.978995] r3 : c0231cec  r2 : bf006000  r1 : bf006000  r0 : c11d3190
    [   13.985559] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
    [   13.992732] Control: 10c5387d  Table: 82dc0019  DAC: 00000055
    [   13.998509] Process systemd-udevd (pid: 242, stack limit = 0xc2db4220)
    [   14.005070] Stack: (0xc2db5d88 to 0xc2db6000)
    [   14.009457] 5d80:                   bf005fff c11d3190 c11d3190 00000001 c1187dc4 c136c540
    [   14.017682] 5da0: bf006000 c11d3190 c2db5dd4 bf006000 00000000 bf006000 bf002180 00000000
    [   14.025907] 5dc0: c118350c bf002080 c2db5e14 c2db5dd8 c0231dc4 c03b310c c2db5de8 0000000c
    [   14.034130] 5de0: c2db5dfc c2db5df0 00000080 00000000 c2db5e4c c0231e10 bf0021ac bf002180
    [   14.042355] 5e00: bf002180 bf0021ac c2db5e24 c2db5e18 c0231e30 c0231d3c c2db5e3c c2db5e28
    [   14.050579] 5e20: c02fd5b4 c0231e1c c0231e10 bf0021ac c2db5e5c c2db5e40 c02ff4f8 c02fd568
    [   14.058802] 5e40: 00000001 bf00208c c2db5f40 bf002180 c2db5f34 c2db5e60 c0301c80 c02ff4ac
    [   14.067025] 5e60: bf002080 c042d74c 00000000 00000000 bf000000 c118350c c0b359cc 00000000
    [   14.075250] 5e80: bf00208c c118350c bf003000 c2db5ea0 bf002190 bf00208c 000014e4 00000000
    [   14.083473] 5ea0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    [   14.091695] 5ec0: 00000000 00000000 6e72656b 00006c65 00000000 00000000 00000000 00000000
    [   14.099918] 5ee0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    [   14.108143] 5f00: 00000000 dc8ba700 00000010 00000000 00000006 b6e73664 0000017b c021c308
    [   14.116367] 5f20: c2db4000 00000000 c2db5fa4 c2db5f38 c0302120 c03009ac 00000002 00000000
    [   14.124590] 5f40: d0851000 000014e4 d0851f0c d085180b d0851ca4 00003000 00003110 00000000
    [   14.132814] 5f60: 00000000 00000000 00001538 0000001b 0000001c 00000014 00000011 0000000d
    [   14.141036] 5f80: 00000000 00000000 00000000 7f611780 00000000 00000000 00000000 c2db5fa8
    [   14.149259] 5fa0: c021c140 c0302090 7f611780 00000000 00000006 b6e73664 00000000 7f611830
    [   14.157484] 5fc0: 7f611780 00000000 00000000 0000017b 00000000 00000000 00020000 80a76238
    [   14.165707] 5fe0: be8c8058 be8c8048 b6e69de0 b6d8db40 60010010 00000006 45145044 91104437
    [   14.173957] [<c03b333c>] (apply_to_page_range) from [<c0231dc4>] (change_memory_common+0x94/0xe0)
    [   14.182888] [<c0231dc4>] (change_memory_common) from [<c0231e30>] (set_memory_ro+0x20/0x28)
    [   14.191307] [<c0231e30>] (set_memory_ro) from [<c02fd5b4>] (frob_rodata+0x58/0x6c)
    [   14.198930] [<c02fd5b4>] (frob_rodata) from [<c02ff4f8>] (module_enable_ro+0x58/0x60)
    [   14.206811] [<c02ff4f8>] (module_enable_ro) from [<c0301c80>] (load_module+0x12e0/0x1548)
    [   14.215039] [<c0301c80>] (load_module) from [<c0302120>] (SyS_finit_module+0x9c/0xd8)
    [   14.222920] [<c0302120>] (SyS_finit_module) from [<c021c140>] (ret_fast_syscall+0x0/0x34)
    [   14.231148] Code: e3500000 1afffff4 e51a3008 eaffffe5 (e7f001f2)
    [   14.237282] ---[ end trace e25b4430ecf4fcdd ]---


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
