Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 415916B03D6
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 16:22:43 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b140so15439048wme.3
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 13:22:43 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 92si5884192wra.335.2017.03.08.13.22.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 13:22:41 -0800 (PST)
Date: Wed, 8 Mar 2017 16:16:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] radix-tree: Remove 'private' parameter to functions
Message-ID: <20170308211653.GA10366@cmpxchg.org>
References: <20170308130932.GY16328@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308130932.GY16328@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org

On Wed, Mar 08, 2017 at 05:09:32AM -0800, Matthew Wilcox wrote:
> 
> Hey Johannes, could I get your Acked-by on this?
> 
> For the xarray, I'm thinking about moving some of this logic into the
> xarray (controlled by a bit on the xarray so it's opt-in per xarray),
> so that we can defrag nodes which are on the LRU lists.
> 
> -----8<-----
> 
> Now that radix_tree_node carries a pointer to the root, we no longer
> have to pass the mapping pointer into workingset_update_node().
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Yep, this looks good to me.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
