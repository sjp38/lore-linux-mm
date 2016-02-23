Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 618C16B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:41:04 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id c200so235085351wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:41:04 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 65si41274393wmc.1.2016.02.23.10.41.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 10:41:03 -0800 (PST)
Date: Tue, 23 Feb 2016 10:40:58 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 04/27] mm, vmscan: Move lru_lock to the node
Message-ID: <20160223184058.GD13816@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-5-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456239890-20737-5-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 03:04:27PM +0000, Mel Gorman wrote:
> Node-based reclaim requires node-based LRUs and locking. This is a
> preparation patch that just moves the lru_lock to the node so later patches
> are easier to review. It is a mechanical change but note this patch makes
> contention worse because the LRU lock is hotter and direct reclaim and kswapd
> can contend on the same lock even when reclaiming from different zones.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Reviewing mechanical patches like these is error prone, but nothing
obviously broken stands out to me here.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
