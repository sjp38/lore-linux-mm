Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2F46B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 19:37:04 -0400 (EDT)
Received: by mail-bk0-f47.google.com with SMTP id w10so37669bkz.34
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 16:37:03 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id yp6si274165bkb.162.2014.04.07.16.37.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 16:37:03 -0700 (PDT)
Date: Mon, 7 Apr 2014 19:36:57 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm: page_alloc: Do not cache reclaim distances
Message-ID: <20140407233657.GP4407@cmpxchg.org>
References: <1396910068-11637-1-git-send-email-mgorman@suse.de>
 <1396910068-11637-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1396910068-11637-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 07, 2014 at 11:34:28PM +0100, Mel Gorman wrote:
> pgdat->reclaim_nodes tracks if a remote node is allowed to be reclaimed by
> zone_reclaim due to its distance. As it is expected that zone_reclaim_mode
> will be rarely enabled it is unreasonable for all machines to take a penalty.
> Fortunately, the zone_reclaim_mode() path is already slow and it is the path
> that takes the hit.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
