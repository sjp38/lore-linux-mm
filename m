Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 582CD6B0260
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 08:28:32 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so146735624wib.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 05:28:31 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id i2si8166077wjz.123.2015.07.23.05.28.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jul 2015 05:28:30 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id F0CC2983CE
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 12:28:29 +0000 (UTC)
Date: Thu, 23 Jul 2015 13:28:28 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 03/10] mm, page_alloc: Remove unnecessary recalculations
 for dirty zone balancing
Message-ID: <20150723122827.GB2660@techsingularity.net>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-4-git-send-email-mgorman@suse.com>
 <alpine.DEB.2.10.1507211703410.12650@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507211703410.12650@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 21, 2015 at 05:08:42PM -0700, David Rientjes wrote:
> On Mon, 20 Jul 2015, Mel Gorman wrote:
> 
> > From: Mel Gorman <mgorman@suse.de>
> > 
> > File-backed pages that will be immediately dirtied are balanced between
> > zones but it's unnecessarily expensive. Move consider_zone_balanced into
> > the alloc_context instead of checking bitmaps multiple times.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 

Thanks.

> consider_zone_dirty eliminates zones over their dirty limits and 
> zone_dirty_ok() returns true if zones are under their dirty limits, so the 
> naming of both are a little strange.  You might consider changing them 
> while you're here.

Yeah, that seems sensible. I named the struct field spread_dirty_page so
the relevant check now looks like

	if (ac->spread_dirty_page && !zone_dirty_ok(zone))

Alternative suggestions welcome but I think this is more meaningful than
consider_zone_dirty was.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
