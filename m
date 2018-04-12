Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 696CE6B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 20:54:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v19so1764666pfn.7
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 17:54:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 137sor487733pgd.266.2018.04.11.17.54.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Apr 2018 17:54:58 -0700 (PDT)
Date: Thu, 12 Apr 2018 09:54:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 0/2] Fix __GFP_ZERO vs constructor
Message-ID: <20180412005451.GB253442@rodete-desktop-imager.corp.google.com>
References: <20180411060320.14458-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180411060320.14458-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Chris Fries <cfries@google.com>, jaegeuk@kernel.org

Matthew,

Please Cced relevant people so they know what's going on the problem
they spent on much time. Everyone doesn't keep an eye on mailing list.

On Tue, Apr 10, 2018 at 11:03:18PM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> v1->v2:
>  - Added review/ack tags (thanks!)
>  - Switched the order of the patches
>  - Reworded commit message of the patch which actually fixes the bug
>  - Moved slab debug patches under CONFIG_DEBUG_VM to check _every_
>    allocation and added checks in the slowpath for the allocations which
>    end up allocating a page.
> 
> Matthew Wilcox (2):
>   Fix NULL pointer in page_cache_tree_insert
>   slab: __GFP_ZERO is incompatible with a constructor
> 
>  mm/filemap.c | 9 ++++-----
>  mm/slab.c    | 7 ++++---
>  mm/slab.h    | 7 +++++++
>  mm/slob.c    | 4 +++-
>  mm/slub.c    | 5 +++--
>  5 files changed, 21 insertions(+), 11 deletions(-)
> 
> -- 
> 2.16.3
> 
