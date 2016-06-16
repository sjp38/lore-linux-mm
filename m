Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id E60586B025F
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:59:09 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id c1so5947288lbw.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 01:59:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c132si3401398wma.108.2016.06.16.01.59.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 01:59:08 -0700 (PDT)
Subject: Re: [PATCH 09/27] mm, vmscan: By default have direct reclaim only
 shrink once per node
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-10-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a65c3566-e17e-c01d-2aa8-529122c1c140@suse.cz>
Date: Thu, 16 Jun 2016 10:59:03 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-10-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> Direct reclaim iterates over all zones in the zonelist and shrinking them
> but this is in conflict with node-based reclaim. In the default case,
> only shrink once per node.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
