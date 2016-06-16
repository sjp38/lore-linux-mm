Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 031FF6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:13:54 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c82so28974490wme.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:13:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z137si17384904wmz.112.2016.06.16.08.13.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 08:13:53 -0700 (PDT)
Subject: Re: [PATCH 14/27] mm, workingset: Make working set detection
 node-aware
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-15-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <71c0c1c1-0a5c-2d76-d16b-e4d29a18a6b8@suse.cz>
Date: Thu, 16 Jun 2016 17:13:51 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-15-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> Working set and refault detection is still zone-based, fix it.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

If you wanted, workingset_eviction() could obtain pgdat without going 
through zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
