Received: from localhost.localdomain ([127.0.0.1]:36066 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20038524AbXA3QlI (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 30 Jan 2007 16:41:08 +0000
Date: Tue, 30 Jan 2007 16:41:03 +0000
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [patch] mm: mremap correct rmap accounting
Message-ID: <20070130164103.GA1633@linux-mips.org>
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com> <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com> <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org> <Pine.LNX.4.64.0701292002310.16279@blonde.wat.veritas.com> <Pine.LNX.4.64.0701291219040.3611@woody.linux-foundation.org> <Pine.LNX.4.64.0701292029390.20859@blonde.wat.veritas.com> <Pine.LNX.4.64.0701292107510.26482@blonde.wat.veritas.com> <45BF5520.3040306@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45BF5520.3040306@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 30, 2007 at 03:24:32PM +0100, Carsten Otte wrote:

> Hugh Dickins wrote:
> >I've no idea if the intersection of filemap_xip users and
> >MIPS users is the empty set or more interesting.
> As far as I can tell, the intersection is zero. There is no block 
> device driver one could use for XIP on mips platforms.

How about flash ;-)

XIP is mostly an embedded feature.  The affected MIPS R4[40]00[SM]C
processors are desktop and server processors so there almost
fundamentally is no overlap.

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
