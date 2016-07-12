Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 093EE6B0253
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 15:10:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r190so19594614wmr.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 12:10:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e191si5198062wmd.81.2016.07.12.12.10.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 12:10:33 -0700 (PDT)
Date: Tue, 12 Jul 2016 15:10:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 31/34] mm: vmstat: replace __count_zone_vm_events with a
 zone id equivalent
Message-ID: <20160712191029.GC8629@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-32-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-32-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:35:07AM +0100, Mel Gorman wrote:
> This is partially a preparation patch for more vmstat work but it also has
> the slight advantage that __count_zid_vm_events is cheaper to calculate
> than __count_zone_vm_events().
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
