Received: from sbustd.stud.uni-sb.de (IDENT:2YAFXw/blW/Kyt8r5WusaUCmoBlAbys8@eris.rz.uni-sb.de [134.96.7.8])
	by indyio.rz.uni-sb.de (8.9.3/8.9.3) with ESMTP id OAA4119877
	for <linux-mm@kvack.org>; Wed, 28 Jul 1999 14:28:30 +0200 (CST)
Received: from colorfullife.com (IDENT:manfreds@acc3-200.telip.uni-sb.de [134.96.127.200])
	by sbustd.stud.uni-sb.de (8.9.3/8.9.3) with ESMTP id OAA08510
	for <linux-mm@kvack.org>; Wed, 28 Jul 1999 14:28:28 +0200 (CST)
Message-ID: <379EF7D0.375C78A4@colorfullife.com>
Date: Wed, 28 Jul 1999 14:30:08 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
Reply-To: masp0008@stud.uni-sb.de
MIME-Version: 1.0
Subject: active_mm & SMP & TLB flush: possible bug
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I think that active_mm breaks CLEVER_SMP_INVALIDATE
(linux/asm-i386/pgtable.h)
(version 2.3.11)

e.g. flush_tlb():
CPU 1 executes thread A, CPU2 waits in
the idle thread with a lazy TLB context of thread A.

CPU1: flush_tlb() causes no IPI because
current->mm->mm_users is still 1.

if these 2 CPU switch their roles, then we use an outdates
TLB cache.

-------------
BTW, where can I find more details about the active_mm implementation?
specifically, I'd like to know why active_mm was added to
"struct task_struct".
>From my first impression, it's a CPU specific information
(every CPU has exactly one active_mm, threads which are not running have
no
active_mm), so I'd have used a global array[NR_CPUS].


	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
