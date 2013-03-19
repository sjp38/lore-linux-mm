Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 9E8F06B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 07:06:52 -0400 (EDT)
Date: Tue, 19 Mar 2013 11:06:48 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 07/10] mm: vmscan: Block kswapd if it is encountering
 pages under writeback
Message-ID: <20130319110648.GL2055@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-8-git-send-email-mgorman@suse.de>
 <m21ubejd2p.fsf@firstfloor.org>
 <20130317151917.GD2026@suse.de>
 <20130317154013.GC20853@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130317154013.GC20853@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Sun, Mar 17, 2013 at 04:40:13PM +0100, Andi Kleen wrote:
> > > BTW longer term the code would probably be a lot clearer with a
> > > real explicit state machine instead of all these custom state bits.
> > > 
> > 
> > I would expect so even though it'd be a major overhawl.
> 
> A lot of these VM paths need overhaul because they usually don't
> do enough page batching to perform really well on larger systems.
> 

While I agree this is also a serious issue and one you brought up last year,
the issue here is that page reclaim is making bad decisions for ordinary
machines. The figures in the leader patch show that a single-threaded
background write is enough to push an active application into swap.

For reclaim, the batching that is meant to mitigate part of this problem
is page lruvecs but that has been causing its own problems recently. At
some point the bullet will have to be bitten by removing pagevecs, seeing
what falls out and then design and implement a better batching mechanism
for handling large numbers of struct pages.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
