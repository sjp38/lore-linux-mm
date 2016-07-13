Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDE6C6B0260
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:16:37 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so34850321wma.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:16:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p125si1401978wmp.76.2016.07.13.06.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 06:16:36 -0700 (PDT)
Date: Wed, 13 Jul 2016 09:16:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/4] mm: move most file-based accounting to the node -fix
Message-ID: <20160713131633.GF9905@cmpxchg.org>
References: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
 <1468404004-5085-5-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468404004-5085-5-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 13, 2016 at 11:00:04AM +0100, Mel Gorman wrote:
> As noted by Johannes Weiner, NR_ZONE_WRITE_PENDING gets decremented twice
> during migration instead of a dec(old) -> inc(new) cycle as intended.
> 
> This is a fix to mmotm patch
> mm-move-most-file-based-accounting-to-the-node.patch
> 
> Note that it'll cause a conflict with
> mm-vmstat-remove-zone-and-node-double-accounting-by-approximating-retries.patch
> but that the resolution is trivial.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
