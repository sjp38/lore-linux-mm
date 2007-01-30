Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l0UEOX1n119618
	for <linux-mm@kvack.org>; Tue, 30 Jan 2007 14:24:33 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0UEOWPP1433834
	for <linux-mm@kvack.org>; Tue, 30 Jan 2007 15:24:32 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0UEOWox020339
	for <linux-mm@kvack.org>; Tue, 30 Jan 2007 15:24:32 +0100
Message-ID: <45BF5520.3040306@de.ibm.com>
Date: Tue, 30 Jan 2007 15:24:32 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [patch] mm: mremap correct rmap accounting
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com> <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com> <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org> <Pine.LNX.4.64.0701292002310.16279@blonde.wat.veritas.com> <Pine.LNX.4.64.0701291219040.3611@woody.linux-foundation.org> <Pine.LNX.4.64.0701292029390.20859@blonde.wat.veritas.com> <Pine.LNX.4.64.0701292107510.26482@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0701292107510.26482@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> I've no idea if the intersection of filemap_xip users and
> MIPS users is the empty set or more interesting.
As far as I can tell, the intersection is zero. There is no block 
device driver one could use for XIP on mips platforms.

Carsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
