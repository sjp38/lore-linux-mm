Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C804A6B0005
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:42:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f8-v6so2986542eds.6
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:42:59 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id j5-v6si271441edp.51.2018.07.19.01.42.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jul 2018 01:42:58 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 295DA981D9
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 08:42:58 +0000 (UTC)
Date: Thu, 19 Jul 2018 09:42:57 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v3 4/7] dcache: allocate external names from reclaimable
 kmalloc caches
Message-ID: <20180719084257.2qqafzcteqwkb2xd@techsingularity.net>
References: <20180718133620.6205-1-vbabka@suse.cz>
 <20180718133620.6205-5-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180718133620.6205-5-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>

On Wed, Jul 18, 2018 at 03:36:17PM +0200, Vlastimil Babka wrote:
> We can use the newly introduced kmalloc-reclaimable-X caches, to allocate
> external names in dcache, which will take care of the proper accounting
> automatically, and also improve anti-fragmentation page grouping.
> 
> This effectively reverts commit f1782c9bc547 ("dcache: account external names
> as indirectly reclaimable memory") and instead passes __GFP_RECLAIMABLE to
> kmalloc(). The accounting thus moves from NR_INDIRECTLY_RECLAIMABLE_BYTES to
> NR_SLAB_RECLAIMABLE, which is also considered in MemAvailable calculation and
> overcommit decisions.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs
