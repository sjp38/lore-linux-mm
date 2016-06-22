Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3E06B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 12:08:57 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so39832741lfa.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 09:08:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c142si1691737wmc.107.2016.06.22.09.08.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Jun 2016 09:08:56 -0700 (PDT)
Subject: Re: [PATCH 21/27] mm, vmscan: Only wakeup kswapd once per node for
 the requested classzone
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-22-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <23a86eb7-ffa2-4269-3acb-47b29d984a3c@suse.cz>
Date: Wed, 22 Jun 2016 18:08:54 +0200
MIME-Version: 1.0
In-Reply-To: <1466518566-30034-22-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/21/2016 04:16 PM, Mel Gorman wrote:
> kswapd is woken when zones are below the low watermark but the wakeup
> decision is not taking the classzone into account.  Now that reclaim is
> node-based, it is only required to wake kswapd once per node and only if
> all zones are unbalanced for the requested classzone.
>
> Note that one node might be checked multiple times if the zonelist is ordered
> by node because there is no cheap way of tracking what nodes have already
> been visited. For zone-ordering, each node should be checked only once.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
