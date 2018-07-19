Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C62EF6B026C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:46:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id v26-v6so2990806eds.9
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:46:03 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id q30-v6si2153539edi.5.2018.07.19.01.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 01:46:02 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 4B5CA1C1B1F
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:46:02 +0100 (IST)
Date: Thu, 19 Jul 2018 09:46:01 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v3 7/7] mm, slab: shorten kmalloc cache names for large
 sizes
Message-ID: <20180719084601.bl7zeq3ube7vulgq@techsingularity.net>
References: <20180718133620.6205-1-vbabka@suse.cz>
 <20180718133620.6205-8-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180718133620.6205-8-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>

On Wed, Jul 18, 2018 at 03:36:20PM +0200, Vlastimil Babka wrote:
> Kmalloc cache names can get quite long for large object sizes, when the sizes
> are expressed in bytes. Use 'k' and 'M' prefixes to make the names as short
> as possible e.g. in /proc/slabinfo. This works, as we mostly use power-of-two
> sizes, with exceptions only below 1k.
> 
> Example: 'kmalloc-4194304' becomes 'kmalloc-4M'
> 
> Suggested-by: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

There is a slight chance this will break any external tooling that
calculates fragmentation stats for slab/slub if they are particularly
stupid parsers but other than that;

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs
