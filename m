Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 134146B0009
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 11:17:01 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id p65so40139305wmp.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 08:17:01 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g133si15693521wma.66.2016.02.28.08.16.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 08:17:00 -0800 (PST)
Date: Sun, 28 Feb 2016 11:16:56 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 09/27] mm, vmscan: Simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160228161656.GD25622@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-10-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456239890-20737-10-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 03:04:32PM +0000, Mel Gorman wrote:
> kswapd goes through some complex steps trying to figure out if it
> should stay awake based on the classzone_idx and the requested order.
> It is unnecessarily complex and passes in an invalid classzone_idx to
> balance_pgdat().  What matters most of all is whether a larger order has
> been requsted and whether kswapd successfully reclaimed at the previous
> order. This patch irons out the logic to check just that and the end result
> is less headache inducing.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
