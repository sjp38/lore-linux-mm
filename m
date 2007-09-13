Date: Thu, 13 Sep 2007 11:22:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
In-Reply-To: <1189698566.5013.72.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709131122140.9378@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <1189527657.5036.35.camel@localhost>  <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
 <1189698566.5013.72.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007, Lee Schermerhorn wrote:

> Andi thought this was important enough to go in to 23 as a bug fix.  I
> think it's at least as important as the one you acked.  However, I don't
> know that anyone has ever cited a problem with it.  Then again, they
> might not notice if they occasionally leak a mempolicy struct, or use a
> freed or reused one for page allocation.  I'd be happier to see it cook
> in -mm for a while.  So, I'll go ahead and rebase atop Mel's patches.
> 
> Thoughts?

There is the concern about performance issues because of new refcounter 
increments. I thought you said that you wanted to do performance tests 
first?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
