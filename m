Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D45A16B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:36:18 -0400 (EDT)
Received: by wijp15 with SMTP id p15so18064420wij.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:36:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id un9si39187650wjc.60.2015.08.25.07.36.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 07:36:17 -0700 (PDT)
Subject: Re: [PATCH 06/12] mm, page_alloc: Use masks and shifts when
 converting GFP flags to migrate types
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-7-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DC7D60.1060307@suse.cz>
Date: Tue, 25 Aug 2015 16:36:16 +0200
MIME-Version: 1.0
In-Reply-To: <1440418191-10894-7-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/24/2015 02:09 PM, Mel Gorman wrote:
> This patch redefines which GFP bits are used for specifying mobility and
> the order of the migrate types. Once redefined it's possible to convert
> GFP flags to a migrate type with a simple mask and shift. The only downside
> is that readers of OOM kill messages and allocation failures may have been
> used to the existing values but scripts/gfp-translate will help.

Yeah after patches 7 and 8, this is not much of a concern :)

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
