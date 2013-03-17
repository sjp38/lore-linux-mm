Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 965966B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 11:40:15 -0400 (EDT)
Date: Sun, 17 Mar 2013 16:40:13 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 07/10] mm: vmscan: Block kswapd if it is encountering
 pages under writeback
Message-ID: <20130317154013.GC20853@two.firstfloor.org>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-8-git-send-email-mgorman@suse.de>
 <m21ubejd2p.fsf@firstfloor.org>
 <20130317151917.GD2026@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130317151917.GD2026@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

> > BTW longer term the code would probably be a lot clearer with a
> > real explicit state machine instead of all these custom state bits.
> > 
> 
> I would expect so even though it'd be a major overhawl.

A lot of these VM paths need overhaul because they usually don't
do enough page batching to perform really well on larger systems.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
