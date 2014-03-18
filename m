Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f178.google.com (mail-ve0-f178.google.com [209.85.128.178])
	by kanga.kvack.org (Postfix) with ESMTP id A366B6B011E
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:07:00 -0400 (EDT)
Received: by mail-ve0-f178.google.com with SMTP id jw12so7790459veb.23
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 16:07:00 -0700 (PDT)
Received: from mail-ve0-x231.google.com (mail-ve0-x231.google.com [2607:f8b0:400c:c01::231])
        by mx.google.com with ESMTPS id u5si3037133vdo.40.2014.03.18.16.06.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 16:06:59 -0700 (PDT)
Received: by mail-ve0-f177.google.com with SMTP id sa20so7839132veb.36
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 16:06:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140318124107.GA24890@osiris>
References: <20140318124107.GA24890@osiris>
Date: Tue, 18 Mar 2014 16:06:59 -0700
Message-ID: <CA+8MBbKaaYXNV_XZNRp=wn-+3Mqd4+JVoXn_d+eo=PQR17i1SQ@mail.gmail.com>
Subject: Re: [BUG -next] "mm: per-thread vma caching fix 5" breaks s390
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr@hp.com>, Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, Mar 18, 2014 at 5:41 AM, Heiko Carstens
<heiko.carstens@de.ibm.com> wrote:
> Given that this is just an addon patch to Davidlohr's "mm: per-thread
> vma caching" patch I was wondering if something in there is architecture
> specific.
> But it doesn't look like that. So I'm wondering if this only breaks on
> s390?

I'm seeing this same BUG_ON() on ia64 (when trying out next-20140318)

Starting HAkernel BUG at mm/vmacache.c:76!
L daemon7[?25lps[3259]: bugcheck! 0 [1]
Modules linked in: mptctl

CPU: 0 PID: 3259 Comm: ps Not tainted 3.14.0-rc7-zx1-smp-next-20140318 #1
Hardware name: hp server rx2620                   , BIOS 03.17
                                                   03/31/2005
task: e000000001070000 ti: e000000001070c80 task.ti: e000000001070c80
psr : 0000101008526038 ifs : 8000000000000309 ip  :
[<a00000010019a930>]    Not tainted (3.14.0-rc7-zx1-smp-next-20140318)
ip is at vmacache_find+0x1d0/0x1e0
unat: 0000000000000000 pfs : 0000000000000309 rsc : 0000000000000003
rnat: 0009804c0270033f bsps: a00000010153e470 pr  : 0000000019a99565
ldrs: 0000000000000000 ccv : 00000010e0bb89b1 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000010019a930 b6  : a0000001006cff20 b7  : a0000001006d1a40
f6  : 1003e000000167080aa40 f7  : 1003e0000000000000514
f8  : 1003e000000167080a52c f9  : 1003e0000000000000001
f10 : 1003e501ac672552bd930 f11 : 1003e0000000000000004
r1  : a00000010176aa00 r2  : a00000010153e468 r3  : a00000010156b5e0
r8  : 000000000000001f r9  : 0000000000001b14 r10 : ffffffffffffffff
r11 : 0000000000000000 r12 : e000000001077df0 r13 : e000000001070000
r14 : a00000010153e470 r15 : a00000010153e470 r16 : 000000001b140d8a
r17 : 0000000000000000 r18 : 0000000000007fff r19 : 0000000000000182
r20 : 0000000000000003 r21 : 0000000000000000 r22 : 0000000000000182
r23 : a00000010130a9a8 r24 : a0000001006cff20 r25 : a00000010130a9a8
r26 : a0000001006cff20 r27 : a000000101544658 r28 : a0000001015e2508
r29 : a00000010130a998 r30 : a0000001006cfec0 r31 : a0000001015e23e0

Call Trace:
 [<a000000100015460>] show_stack+0x80/0xa0
                                sp=e0000000010779b0 bsp=e0000000010712e0
 [<a000000100015ac0>] show_regs+0x640/0x920
                                sp=e000000001077b80 bsp=e000000001071288
 [<a0000001000424c0>] die+0x1a0/0x2e0
                                sp=e000000001077b90 bsp=e000000001071248
 [<a000000100042650>] die_if_kernel+0x50/0x80
                                sp=e000000001077b90 bsp=e000000001071218
 [<a000000100f3df10>] ia64_bad_break+0x3d0/0x6e0
                                sp=e000000001077b90 bsp=e0000000010711e8
 [<a00000010000c740>] ia64_native_leave_kernel+0x0/0x270
                                sp=e000000001077c20 bsp=e0000000010711e8
 [<a00000010019a930>] vmacache_find+0x1d0/0x1e0
                                sp=e000000001077df0 bsp=e0000000010711a0
 [<a0000001001b4cb0>] find_vma+0x30/0x140
                                sp=e000000001077df0 bsp=e000000001071170
 [<a0000001001b4df0>] find_extend_vma+0x30/0x140
                                sp=e000000001077df0 bsp=e000000001071138
 [<a0000001001a9080>] __get_user_pages+0x120/0xd60
                                sp=e000000001077df0 bsp=e000000001071010
 [<a0000001001a9dd0>] get_user_pages+0x70/0xa0
                                sp=e000000001077e10 bsp=e000000001070fb0
 [<a0000001001a9eb0>] __access_remote_vm+0xb0/0x360
                                sp=e000000001077e10 bsp=e000000001070f18
 [<a0000001001aa1c0>] access_process_vm+0x60/0xa0
                                sp=e000000001077e20 bsp=e000000001070ed0
 [<a00000010018a390>] get_cmdline+0xb0/0x240
                                sp=e000000001077e20 bsp=e000000001070e88
 [<a0000001002ca2f0>] proc_pid_cmdline+0x30/0x60
                                sp=e000000001077e20 bsp=e000000001070e60
 [<a0000001002c7880>] proc_info_read+0x120/0x200
                                sp=e000000001077e20 bsp=e000000001070e10
 [<a000000100201da0>] vfs_read+0x140/0x340
                                sp=e000000001077e20 bsp=e000000001070dc0
 [<a000000100202180>] SyS_read+0xa0/0x120
                                sp=e000000001077e20 bsp=e000000001070d40
 [<a00000010000c5c0>] ia64_ret_from_syscall+0x0/0x20
                                sp=e000000001077e30 bsp=e000000001070d40
 [<a000000000040720>] ia64_ivt+0xffffffff00040720/0x400
                                sp=e000000001078000 bsp=e000000001070d40
Disabling lock debugging due to kernel taint

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
