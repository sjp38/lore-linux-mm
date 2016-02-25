Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id F1D126B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 17:17:52 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id a4so47069438wme.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:17:52 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id rx6si12225659wjb.4.2016.02.25.14.17.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 14:17:51 -0800 (PST)
Date: Thu, 25 Feb 2016 17:17:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 07/27] mm, vmscan: Have kswapd only scan based on the
 highest requested zone
Message-ID: <20160225221746.GA12258@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-8-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456239890-20737-8-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 03:04:30PM +0000, Mel Gorman wrote:
> kswapd checks all eligible zones to see if they need balancing even if it was
> woken for a lower zone. This made sense when we reclaimed on a per-zone basis
> because we wanted to shrink zones fairly so avoid age-inversion problems.
> Ideally this is completely unnecessary when reclaiming on a per-node basis.
> In theory, there may still be anomalies when all requests are for lower
> zones and very old pages are preserved in higher zones but this should be
> the exceptional case.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

As I mentioned in the other subthread, this should probably be fine,
although it would be good, generally, to have some sort of statistics
on how much of the age-distorting reclaim is happening, and then maybe
mention its existence in the changelog of this patch. Just an idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
