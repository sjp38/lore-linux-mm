MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16870.62464.192905.778878@wombat.chubb.wattle.id.au>
Date: Fri, 14 Jan 2005 09:19:44 +1100
From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: Re: page table lock patch V15 [0/7]: overview
In-Reply-To: <41E5C3E6.90906@yahoo.com.au>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
	<Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org>
	<Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412011545060.5721@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com>
	<m1652ddljp.fsf@muc.de>
	<Pine.LNX.4.58.0501110937450.32744@schroedinger.engr.sgi.com>
	<41E4BCBE.2010001@yahoo.com.au>
	<20050112014235.7095dcf4.akpm@osdl.org>
	<Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com>
	<20050112104326.69b99298.akpm@osdl.org>
	<41E5AFE6.6000509@yahoo.com.au>
	<20050112153033.6e2e4c6e.akpm@osdl.org>
	<41E5B7AD.40304@yahoo.com.au>
	<Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com>
	<41E5BC60.3090309@yahoo.com.au>
	<Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com>
	<41E5C3E6.90906@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

Nick> I would say that having arch-definable accessors for
Nick> the page tables wouldn't be a bad idea anyway, and the
Nick> flexibility may come in handy for other things.

Nick> It would be a big, annoying patch though :(

We're currently working in a slightly different direction, to try to
hide page-table implemention details from anything outside the page table
implementation.  Our goal is to be able to try out other page tables
(e.g., Liedtke's guarded page table) instead of the 2/3/4 level fixed
hierarchy.

We're currently working on a 2.6.10 snapshot; obviously we'll have to
roll up to 2.6.11 before releasing (and there are lots of changes
there because of the recent 4-layer page table implementation).

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
