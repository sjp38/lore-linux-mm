Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A6D546B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:46:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 4so29087286wmz.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:46:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2si616839wma.8.2016.06.16.08.46.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 08:46:00 -0700 (PDT)
Subject: Re: [PATCH 15/27] mm, page_alloc: Consider dirtyable memory in terms
 of nodes
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-16-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ffdd6a49-d3f7-38df-a875-f3f3b2d8674b@suse.cz>
Date: Thu, 16 Jun 2016 17:45:58 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-16-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> Historically dirty pages were spread among zones but now that LRUs are
> per-node it is more appropriate to consider dirty pages in a node.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
