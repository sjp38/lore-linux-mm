Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 19DED6B0254
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 08:19:16 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so42808409wic.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 05:19:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q8si9553356wiz.6.2015.08.26.05.19.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Aug 2015 05:19:14 -0700 (PDT)
Subject: Re: [PATCH 08/12] mm, page_alloc: Rename __GFP_WAIT to __GFP_RECLAIM
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-9-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DDAEBE.8090708@suse.cz>
Date: Wed, 26 Aug 2015 14:19:10 +0200
MIME-Version: 1.0
In-Reply-To: <1440418191-10894-9-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/24/2015 02:09 PM, Mel Gorman wrote:
> __GFP_WAIT was used to signal that the caller was in atomic context and
> could not sleep.  Now it is possible to distinguish between true atomic
> context and callers that are not willing to sleep. The latter should clear
> __GFP_DIRECT_RECLAIM so kswapd will still wake. As clearing __GFP_WAIT
> behaves differently, there is a risk that people will clear the wrong
> flags. This patch renames __GFP_WAIT to __GFP_RECLAIM to clearly indicate
> what it does -- setting it allows all reclaim activity, clearing them
> prevents it.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
