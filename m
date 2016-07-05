Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 684DC6B0253
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 06:55:29 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g18so137053192lfg.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 03:55:29 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id w10si2730588wja.42.2016.07.05.03.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 03:55:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id E03211C1478
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 11:55:27 +0100 (IST)
Date: Tue, 5 Jul 2016 11:55:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 31/31] mm, vmstat: Remove zone and node double accounting
 by approximating retries
Message-ID: <20160705105526.GK11498@techsingularity.net>
References: <00f601d1d691$d790ad40$86b207c0$@alibaba-inc.com>
 <00fa01d1d694$42f6a7e0$c8e3f7a0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <00fa01d1d694$42f6a7e0$c8e3f7a0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jul 05, 2016 at 04:07:23PM +0800, Hillf Danton wrote:
> > +		/*
> > +		 * Would the allocation succeed if we reclaimed the whole
> > +		 * available? This is approximate because there is no
> > +		 * accurate count of reclaimable pages per zone.
> > +		 */
> > +		for (zid = 0; zid <= zone_idx(zone); zid++) {
> > +			struct zone *check_zone = &current_pgdat->node_zones[zid];
> > +			unsigned long estimate;
> > +
> > +			estimate = min(check_zone->managed_pages, available);
> > +			if (__zone_watermark_ok(check_zone, order,
> > +					min_wmark_pages(check_zone), ac_classzone_idx(ac),
> > +					alloc_flags, available)) {
> > +			}
> Stray indent?
> 

Last minute rebase-related damage. I'll fix it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
