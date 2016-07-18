Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B781D6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 12:16:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so62256015wmr.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 09:16:02 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m1si15631737wme.56.2016.07.18.09.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 09:16:01 -0700 (PDT)
Date: Mon, 18 Jul 2016 12:15:57 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/5] mm, vmscan: avoid passing in classzone_idx
 unnecessarily to compaction_ready -fix
Message-ID: <20160718161557.GE16465@cmpxchg.org>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
 <1468588165-12461-3-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468588165-12461-3-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 15, 2016 at 02:09:22PM +0100, Mel Gorman wrote:
> As pointed out by Vlastimil, there is a redundant check in shrink_zones
> since commit "mm, vmscan: avoid passing in classzone_idx unnecessarily to
> compaction_ready".  The zonelist iterator only returns zones that already
> meet the requirements of the allocation request.
> 
> This is a fix to the mmotm patch
> mm-vmscan-avoid-passing-in-classzone_idx-unnecessarily-to-compaction_ready.patch
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
