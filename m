Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B45CD6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 12:26:50 -0400 (EDT)
Date: Mon, 15 Jun 2009 17:28:16 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090615172816.707bff0a@lxorguk.ukuu.org.uk>
In-Reply-To: <20090615161904.GH31969@one.firstfloor.org>
References: <20090615024520.786814520@intel.com>
	<4A35BD7A.9070208@linux.vnet.ibm.com>
	<20090615042753.GA20788@localhost>
	<Pine.LNX.4.64.0906151341160.25162@sister.anvils>
	<20090615140019.4e405d37@lxorguk.ukuu.org.uk>
	<20090615132934.GE31969@one.firstfloor.org>
	<20090615154832.73c89733@lxorguk.ukuu.org.uk>
	<20090615152427.GF31969@one.firstfloor.org>
	<20090615162804.4cb75b30@lxorguk.ukuu.org.uk>
	<20090615161904.GH31969@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > 	curse a lot
> > 	suspend to disk
> > 	remove dirt from fans, clean/replace RAM
> > 	resume from disk
> > 
> > The very act of making the ECC error not take out the box creates the
> 
> Ok so at least you agree now that handling these errors without 
> panic is the right thing to do. That's at least some progress.

There are some situations it may be useful - possibly. But then if you
can't sort the resulting mess out because your patches are too limited
its not useful yet is it.

Even then this isn't 2.6.31 stuff - its 2.6.31-mm or -next stuff maybe
for 2.6.32

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
