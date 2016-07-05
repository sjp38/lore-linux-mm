Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C13ED6B0253
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 06:49:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so85202682wme.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 03:49:31 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id pg5si3444894wjb.179.2016.07.05.03.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 03:49:30 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 45EFE1C1EF4
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 11:49:30 +0100 (IST)
Date: Tue, 5 Jul 2016 11:49:28 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 21/31] mm, page_alloc: Wake kswapd based on the highest
 eligible zone
Message-ID: <20160705104928.GJ11498@techsingularity.net>
References: <00e101d1d689$b9a1d730$2ce58590$@alibaba-inc.com>
 <00e201d1d68a$84b72100$8e256300$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <00e201d1d68a$84b72100$8e256300$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jul 05, 2016 at 02:57:38PM +0800, Hillf Danton wrote:
> > 
> > The ac_classzone_idx is used as the basis for waking kswapd and that is based
> > on the preferred zoneref. If the preferred zoneref's highest zone is lower
> > than what is available on other nodes, it's possible that kswapd is woken
> > on a zone with only higher, but still eligible, zones. As classzone_idx
> > is strictly adhered to now, it causes a problem because eligible pages
> > are skipped.
> > 
> > For example, node 0 has only DMA32 and node 1 has only NORMAL. An allocating
> > context running on node 0 may wake kswapd on node 1 telling it to skip
> > all NORMAL pages.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > ---
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> 

Thanks. I also noticed when applying the ack that "zoneref's highest
zone" should have been "zoneref's first zone" so fixed that too.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
