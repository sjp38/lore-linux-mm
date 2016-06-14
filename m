Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF81A6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 10:53:01 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l184so20282491lfl.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 07:53:01 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id j9si29931718wjt.128.2016.06.14.07.53.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Jun 2016 07:53:00 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id DE95798DBC
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 14:52:59 +0000 (UTC)
Date: Tue, 14 Jun 2016 15:52:58 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 06/27] mm, vmscan: Make kswapd reclaim in terms of nodes
Message-ID: <20160614145258.GD1868@techsingularity.net>
References: <02fe01d1c48b$c44e9e80$4cebdb80$@alibaba-inc.com>
 <02ff01d1c48d$78112f40$68338dc0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <02ff01d1c48d$78112f40$68338dc0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sun, Jun 12, 2016 at 05:33:24PM +0800, Hillf Danton wrote:
> > -	/*
> > -	 * We put equal pressure on every zone, unless one zone has way too
> > -	 * many pages free already. The "too many pages" is defined as the
> > -	 * high wmark plus a "gap" where the gap is either the low
> > -	 * watermark or 1% of the zone, whichever is smaller.
> > -	 */
> > -	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
> > -			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
> > +		nr_to_reclaim += max(high_wmark_pages(zone), SWAP_CLUSTER_MAX);
> > +	}
> 
> Missing sc->nr_to_reclaim = nr_to_reclaim; ?
> 

Yes. It may explain why I saw lower than expected kswapd in more
detailed tests recently. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
