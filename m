Received: from mailhost.uni-koblenz.de (mailhost.uni-koblenz.de [141.26.64.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA25731
	for <linux-mm@kvack.org>; Thu, 14 Jan 1999 09:04:31 -0500
Received: from lappi.waldorf-gmbh.de (pmport-28.uni-koblenz.de [141.26.249.28])
	by mailhost.uni-koblenz.de (8.9.1/8.9.1) with ESMTP id PAA08835
	for <linux-mm@kvack.org>; Thu, 14 Jan 1999 15:04:13 +0100 (MET)
Message-ID: <19990114111549.E466@uni-koblenz.de>
Date: Thu, 14 Jan 1999 11:15:49 +0100
From: ralf@uni-koblenz.de
Subject: Re: question about try_to_swap_out()
References: <199901121658.KAA28147@feta.cs.utexas.edu> <199901121814.SAA11098@dax.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199901121814.SAA11098@dax.scot.redhat.com>; from Stephen C. Tweedie on Tue, Jan 12, 1999 at 06:14:49PM +0000
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>, "Paul R. Wilson" <wilson@cs.utexas.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 12, 1999 at 06:14:49PM +0000, Stephen C. Tweedie wrote:

> On Tue, 12 Jan 1999 10:58:52 -0600, "Paul R. Wilson"
> <wilson@cs.utexas.edu> said:
> 
> > I would think that it could be significant if you're skipping DMA
> > pages, which are valuable.  You want to get them back in a timely
> > manner, so you want to go ahead and age them normally.
> 
> We don't ever do that.  We can _require_ a DMA allocation, but we never
> explicitly avoid allocating DMA pages.

Which is a problem for certain machines which have distinct pools of DMA-able
memory and memory for normal use by the processor.

  Ralf
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
