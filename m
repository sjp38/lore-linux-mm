Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04D706B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 04:28:06 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r141so29711023wmg.4
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 01:28:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l74si1751092wmg.126.2017.02.08.01.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 01:28:05 -0800 (PST)
Date: Wed, 8 Feb 2017 09:28:02 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm/page_alloc: Fix nodes for reclaim in fast path
Message-ID: <20170208092802.tejkvuz23iyarnvr@suse.de>
References: <1486532455-29613-1-git-send-email-gwshan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1486532455-29613-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, anton@samba.org, mpe@ellerman.id.au, "# v3 . 16+" <stable@vger.kernel.org>

On Wed, Feb 08, 2017 at 04:40:55PM +1100, Gavin Shan wrote:
> When @node_reclaim_node isn't 0, the page allocator tries to reclaim
> pages if the amount of free memory in the zones are below the low
> watermark. On Power platform, none of NUMA nodes are scanned for page
> reclaim because no nodes match the condition in zone_allows_reclaim().
> On Power platform, RECLAIM_DISTANCE is set to 10 which is the distance
> of Node-A to Node-A. So the preferred node even won't be scanned for
> page reclaim.
> 
> Fixes: 5f7a75acdb24 ("mm: page_alloc: do not cache reclaim distances")
> Cc: <stable@vger.kernel.org> # v3.16+
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
