Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E08A6B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 09:33:36 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 132so17708617lfz.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 06:33:36 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qc10si7896195wjc.175.2016.06.09.06.33.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 06:33:35 -0700 (PDT)
Date: Thu, 9 Jun 2016 09:33:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 07/10] mm: base LRU balancing on an explicit cost model
Message-ID: <20160609133331.GB11719@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-8-hannes@cmpxchg.org>
 <20160608125137.GH22570@dhcp22.suse.cz>
 <20160608161605.GF6727@cmpxchg.org>
 <20160609121802.GD24777@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160609121802.GD24777@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Thu, Jun 09, 2016 at 02:18:02PM +0200, Michal Hocko wrote:
> On Wed 08-06-16 12:16:05, Johannes Weiner wrote:
> > On Wed, Jun 08, 2016 at 02:51:37PM +0200, Michal Hocko wrote:
> > > On Mon 06-06-16 15:48:33, Johannes Weiner wrote:
> > > > Rename struct zone_reclaim_stat to struct lru_cost, and move from two
> > > > separate value ratios for the LRU lists to a relative LRU cost metric
> > > > with a shared denominator.
> > > 
> > > I just do not like the too generic `number'. I guess cost or price would
> > > fit better and look better in the code as well. Up you though...
> > 
> > Yeah, I picked it as a pair, numerator and denominator. But as Minchan
> > points out, denom is superfluous in the final version of the patch, so
> > I'm going to remove it and give the numerators better names.
> > 
> > anon_cost and file_cost?
> 
> Yes that is much more descriptive and easier to grep for. I didn't
> propose that because I thought you would want to preserve the array
> definition for an easier code to update them.

It'll be slightly more verbose, but that's probably a good thing.
Especially for readability in get_scan_count().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
