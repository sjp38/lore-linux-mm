Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 769B36B025E
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 12:14:56 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so118231408lfw.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 09:14:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k3si15573213wma.135.2016.07.18.09.14.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 09:14:55 -0700 (PDT)
Date: Mon, 18 Jul 2016 12:14:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/5] mm, vmscan: make shrink_node decisions more
 node-centric -fix
Message-ID: <20160718161450.GD16465@cmpxchg.org>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
 <1468588165-12461-2-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468588165-12461-2-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 15, 2016 at 02:09:21PM +0100, Mel Gorman wrote:
> The patch "mm, vmscan: make shrink_node decisions more node-centric"
> checks whether compaction is suitable on empty nodes. This is expensive
> rather than wrong but is worth fixing.
> 
> This is a fix to the mmotm patch
> mm-vmscan-make-shrink_node-decisions-more-node-centric.patch
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
