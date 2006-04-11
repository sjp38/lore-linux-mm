Date: Tue, 11 Apr 2006 14:03:31 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm1 0/6] Migrate-on-fault - Overview
Message-ID: <20060411190330.GA21229@sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain> <Pine.LNX.4.64.0604111134350.1027@schroedinger.engr.sgi.com> <200604112052.50133.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200604112052.50133.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, ak@suse.com
List-ID: <linux-mm.kvack.org>

On Tue, Apr 11, 2006 at 08:52:49PM +0200, Andi Kleen wrote:
> On Tuesday 11 April 2006 20:46, Christoph Lameter wrote:
> > However, if the page is not frequently references then the 
> > effort required to migrate the page was not justified.
> 
> I have my doubts the whole thing is really worthwhile. It probably 
> would at least need some statistics to only do this for frequent
> accesses, but I don't know where to put this data.

Agree. And a way to disable the migration-on-fault.

> 
> At least it would be a serious research project to figure out 
> a good way to do automatic migration. From what I was told by
> people who tried this (e.g. in Irix) it is really hard and
> didn't turn out to be a win for them.

IRIX had hardware support for counting offnode vs. onnode references
to a page & sending interrupts when migration appeared to be beneficial

We intended to use this info to migrate pages.  Unfortunately, we were 
never able to demonstrate a performance benefit of migrating pages. 
The overhead always exceeded the cost except in a very small number
of carefully selected benchmarks.


> 
> The better way is to just provide the infrastructure
> and let batch managers or program itselves take care of migration.
> 
> That was the whole idea behind NUMA API - some problems 
> are too hard to figure out automatically by the kernel, so 
> allow the user or application to give it a hand.
> 
> And frankly the defaults we have currently are not that bad,
> perhaps with some small tweaks (e.g. i'm still liking the idea
> of interleaving file cache by default) 
> 
> -Andi
> 

-- 
Jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
