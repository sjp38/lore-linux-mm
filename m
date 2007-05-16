Date: Wed, 16 May 2007 16:12:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/5] Do not annotate shmem allocations explicitly
In-Reply-To: <20070516230150.10314.37438.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705161611530.12119@schroedinger.engr.sgi.com>
References: <20070516230110.10314.85884.sendpatchset@skynet.skynet.ie>
 <20070516230150.10314.37438.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 May 2007, Mel Gorman wrote:

> shmem support allocates pages for two purposes. Firstly, shmem_dir_alloc()
> allocates pages to track swap vectors. These are not movable so this
> patch clears all mobility-flags related to the allocation. Secondly,
> shmem_alloc_pages() allocates pages on behalf of shmem_getpage(), whose
> flags come from a file mapping which already sets the appropriate mobility
> flags. These allocations do not need to be explicitly flagged so this patch
> removes the unnecessary annotations.

I do not feel really competent on shmem.... but

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
