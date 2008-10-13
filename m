In-reply-to: <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu> (message from Miklos
	Szeredi on Mon, 13 Oct 2008 15:59:00 +0200)
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop> <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site> <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu>
Message-Id: <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 13 Oct 2008 16:27:25 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Oct 2008, Miklos Szeredi wrote:
> On Mon, 13 Oct 2008, Nick Piggin wrote:
> > In many cases, yes it seems to. And some of the approaches even if
> > they work now seem like they *might* cause problematic constraints
> > in the design... Have Al and Christoph reviewed the dentry and inode
> > patches?
> 
> This d_invalidate() looks suspicious to me:

And the things kick_inodes() does without any sort of locking look
even more dangerous.

It should be the other way round: first make sure nothing is
referencing the inode, and _then_ start cleaning it up with
appropriate locks held.  See prune_icache().

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
