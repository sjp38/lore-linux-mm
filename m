Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EADFF6B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 07:53:19 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a66so15899835wme.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 04:53:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k66si3780461wmb.105.2016.06.24.04.53.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 04:53:18 -0700 (PDT)
Subject: Re: [PATCH v3 10/17] mm, compaction: cleanup unused functions
References: <20160624095437.16385-1-vbabka@suse.cz>
 <20160624095437.16385-11-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5be2904b-b3c3-174f-a020-89d957a96e14@suse.cz>
Date: Fri, 24 Jun 2016 13:53:17 +0200
MIME-Version: 1.0
In-Reply-To: <20160624095437.16385-11-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 06/24/2016 11:54 AM, Vlastimil Babka wrote:
> Since kswapd compaction moved to kcompactd, compact_pgdat() is not called
> anymore, so we remove it. The only caller of __compact_pgdat() is
> compact_node(), so we merge them and remove code that was only reachable from
> kswapd.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>

Patch with updated context to apply after the fixed 07/17 patch:
----8<----
