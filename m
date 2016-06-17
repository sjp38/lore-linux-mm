Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0336B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:31:17 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id nq2so5443596lbc.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:31:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iq10si11521706wjb.103.2016.06.17.04.31.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 04:31:16 -0700 (PDT)
Subject: Re: [PATCH 25/27] mm: page_alloc: Cache the last node whose dirty
 limit is reached
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-26-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <654783c8-ffcb-af3f-90be-d6bd62e554e1@suse.cz>
Date: Fri, 17 Jun 2016 13:31:06 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-26-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> If a page is about to be dirtied then the page allocator attempts to limit
> the total number of dirty pages that exists in any given zone. The call
> to node_dirty_ok is expensive so this patch records if the last pgdat
> examined hit the dirty limits. In some cases, this reduces the number
> of calls to node_dirty_ok().
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
