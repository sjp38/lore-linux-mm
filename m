Subject: Re: [PATCH] Document Linux Memory Policy - V2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707311257220.18386@schroedinger.engr.sgi.com>
References: <20070725111646.GA9098@skynet.ie>
	 <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	 <20070726132336.GA18825@skynet.ie>
	 <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
	 <20070726225920.GA10225@skynet.ie>
	 <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
	 <20070727082046.GA6301@skynet.ie> <20070727154519.GA21614@skynet.ie>
	 <Pine.LNX.4.64.0707271026040.15990@schroedinger.engr.sgi.com>
	 <1185559260.5069.40.camel@localhost>  <20070731151434.GA18506@skynet.ie>
	 <1185899686.6240.64.camel@localhost>
	 <Pine.LNX.4.64.0707311206330.6053@schroedinger.engr.sgi.com>
	 <1185911215.6240.100.camel@localhost>
	 <Pine.LNX.4.64.0707311257220.18386@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 31 Jul 2007 16:23:31 -0400
Message-Id: <1185913411.6240.115.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com, Michael Kerrisk <mtk-manpages@gmx.net>, Randy Dunlap <randy.dunlap@oracle.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-31 at 12:58 -0700, Christoph Lameter wrote:
> On Tue, 31 Jul 2007, Lee Schermerhorn wrote:
> > Again, I refuse to bite...
> 
> Please include at least the two sides to it in your doc.

I'm trying not to make any judgmental statements one way or another in
the document.  I don't think it's appropriate there.  Rather, I'm trying
to describe the current behavior.  How well I'm succeeding at this is
open to debate, I guess.

> 
> There are numerous issues with memory policies and I think we are still 
> waiting for a solution that addresses these issues in a consistent way and 
> improves the overall cleanness of the implementation.

I think we need to get the in incremental steps.  

And, I think phrases like "consistent way" and "improves overall
cleanness" are very subjective.  Exchanges will be more constructive if
folks could stop asserting their own opinions as undisputed fact.  E.g.,
see:

	http://www.generalsemantics.org/about/about-gs2.htm

	especially the "Some Formulations..." section

or:
	http://www.generalsemantics.org/about/13-common.htm



Anyway, I'm about to post V3.  Have at it.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
