Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id A64646B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:48:10 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so3176984eek.34
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:48:09 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id y6si1666108eep.347.2014.05.02.06.48.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:48:09 -0700 (PDT)
Date: Fri, 2 May 2014 09:48:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/6] lib: Update the kmemleak stack trace for radix tree
 allocations
Message-ID: <20140502134804.GL23420@cmpxchg.org>
References: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
 <1399038070-1540-4-git-send-email-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399038070-1540-4-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, May 02, 2014 at 02:41:07PM +0100, Catalin Marinas wrote:
> Since radix_tree_preload() stack trace is not always useful for
> debugging an actual radix tree memory leak, this patch updates the
> kmemleak allocation stack trace in the radix_tree_node_alloc() function.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks Catalin!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
