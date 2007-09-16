Date: Sun, 16 Sep 2007 12:34:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
Message-Id: <20070916123459.79e0848a.akpm@linux-foundation.org>
In-Reply-To: <20070916180527.GB15184@skynet.ie>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	<1189527657.5036.35.camel@localhost>
	<Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
	<1189691837.5013.43.camel@localhost>
	<Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
	<20070913182344.GB23752@skynet.ie>
	<Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com>
	<20070913141704.4623ac57.akpm@linux-foundation.org>
	<20070914085335.GA30407@skynet.ie>
	<1189800926.5315.76.camel@localhost>
	<20070916180527.GB15184@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 16 Sep 2007 19:05:27 +0100 mel@skynet.ie (Mel Gorman) wrote:

> > I'm still trying to absorb the patches, but so far they look good.
> > Perhaps Andrew can tack them onto the bottom of the next -mm so that if
> > someone else finds issues, they won't complicate merging earlier patches
> > upstream?
> > 
> 
> I hope so. Andrew, how do you feel about pulling V7 into -mm?

umm, sure, once the churn rate falls to less than one new revision per day?

I need to get rc6-mm1 out, and it'll be crap, and it'll need another -mm shortly
after that to get things vaguely stable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
