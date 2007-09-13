Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <1189527657.5036.35.camel@localhost>
	 <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 13 Sep 2007 11:49:26 -0400
Message-Id: <1189698566.5013.72.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-09-12 at 15:17 -0700, Christoph Lameter wrote:
> On Tue, 11 Sep 2007, Lee Schermerhorn wrote:
> 
> > Andi, Christoph, Mel [added to cc]:
> > 
> > Any comments on these patches, posted 30aug?  I've rebased to
> > 23-rc4-mm1, but before reposting, I wanted to give you a chance to
> > comment.
> 
> Sorry that it took some time but I only just got around to look at them. 
> The one patch that I acked may be of higher priority and should probably 
> go in immediately to be merged for 2.6.24.
> 

One thing I forgot to ask in previous response:

What about patch #1 in the series:  fix reference counting?

Andi thought this was important enough to go in to 23 as a bug fix.  I
think it's at least as important as the one you acked.  However, I don't
know that anyone has ever cited a problem with it.  Then again, they
might not notice if they occasionally leak a mempolicy struct, or use a
freed or reused one for page allocation.  I'd be happier to see it cook
in -mm for a while.  So, I'll go ahead and rebase atop Mel's patches.

Thoughts?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
