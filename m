Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B58826B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 08:53:30 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a20so25675528wme.5
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 05:53:30 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id z3si3767460wme.12.2016.12.06.05.53.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 05:53:29 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id E47591C15B1
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 13:53:28 +0000 (GMT)
Date: Tue, 6 Dec 2016 13:53:28 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm: page_alloc: High-order per-cpu page allocator v5
Message-ID: <20161206135328.lvafbdemb3bjjktv@techsingularity.net>
References: <20161202002244.18453-1-mgorman@techsingularity.net>
 <20161202002244.18453-3-mgorman@techsingularity.net>
 <20161202060346.GA21434@js1304-P5Q-DELUXE>
 <20161202090449.kxktmyf5sdp2sroh@techsingularity.net>
 <20161205030619.GA1378@js1304-P5Q-DELUXE>
 <20161205095739.i5ucbzspnjedupin@techsingularity.net>
 <20161206024345.GA6542@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161206024345.GA6542@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Tue, Dec 06, 2016 at 11:43:45AM +0900, Joonsoo Kim wrote:
> > actually clear at all it's an unfair situation, particularly given that the
> > vanilla code is also unfair -- the vanilla code can artifically preserve
> > MIGRATE_UNMOVABLE without any clear indication that it is a universal win.
> > The only deciding factor there was a fault-intensive workload would mask
> > overhead of the page allocator due to page zeroing cost which UNMOVABLE
> > allocations may or may not require. Even that is vague considering that
> > page-table allocations are zeroing even if many kernel allocations are not.
> 
> "Vanilla works like that" doesn't seem to be reasonable to justify
> this change.  Vanilla code works with three lists and it now become
> six lists and each list can have different size of page. We need to
> think that previous approach will also work fine with current one. I
> think that there is a problem although it's not permanent and would be
> minor. However, it's better to fix it when it is found.
> 

This is going in circles. I prototyped the modification which increases
the per-cpu structure slightly and will evaluate. It takes about a day
to run through the full set of tests. If it causes no harm, I'll release
another version.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
