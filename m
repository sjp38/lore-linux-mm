Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l0UHZ5Pl265734
	for <linux-mm@kvack.org>; Tue, 30 Jan 2007 17:35:05 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0UHZ56q1929328
	for <linux-mm@kvack.org>; Tue, 30 Jan 2007 18:35:05 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0UHZ4X3005395
	for <linux-mm@kvack.org>; Tue, 30 Jan 2007 18:35:04 +0100
Message-ID: <45BF81C8.8050803@de.ibm.com>
Date: Tue, 30 Jan 2007 18:35:04 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [patch] mm: mremap correct rmap accounting
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com> <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com> <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org> <Pine.LNX.4.64.0701292002310.16279@blonde.wat.veritas.com> <Pine.LNX.4.64.0701291219040.3611@woody.linux-foundation.org> <Pine.LNX.4.64.0701292029390.20859@blonde.wat.veritas.com> <Pine.LNX.4.64.0701292107510.26482@blonde.wat.veritas.com> <45BF5520.3040306@de.ibm.com> <20070130164103.GA1633@linux-mips.org>
In-Reply-To: <20070130164103.GA1633@linux-mips.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ralf Baechle <ralf@linux-mips.org>
Cc: carsteno@de.ibm.com, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Ralf Baechle wrote:
> How about flash ;-)
The current xip implementation does not work with flash. It only works 
with ram/rom, and we use it in a virtual environment to share data 
between multiple virtual machines.
After a long discussion with Joern Engel and David Woodhouse, I 
believe we came up with an idea how we would extend the existing xip 
support to work with memory technology device. But that is not 
implemented, and not work in progress.

> XIP is mostly an embedded feature.  The affected MIPS R4[40]00[SM]C
> processors are desktop and server processors so there almost
> fundamentally is no overlap.
Actually, only few people consider s390 as embedded platform. And s390 
is the only exploiter of xip to date.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
