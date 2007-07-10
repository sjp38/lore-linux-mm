Date: Tue, 10 Jul 2007 11:47:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: -mm merge plans -- anti-fragmentation
In-Reply-To: <20070710135554.GC9426@skynet.ie>
Message-ID: <Pine.LNX.4.64.0707101147160.11906@schroedinger.engr.sgi.com>
References: <20070710102043.GA20303@skynet.ie> <20070710130356.GG8779@wotan.suse.de>
 <20070710135554.GC9426@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007, Mel Gorman wrote:

> > > >  These are slub changes which are dependent on Mel's stuff, and I have a note
> > > >  here that there were reports of page allocation failures with these.  What's
> > > >  up with that?

As far as I know these were resolved by some of Mel's changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
