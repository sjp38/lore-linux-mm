Date: Mon, 14 Apr 2008 12:41:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: RIP __kmem_cache_shrink (was Re: [patch 15/18] FS: Proc filesystem
 support for slab defrag)
In-Reply-To: <20080413133929.GA21007@martell.zuzino.mipt.ru>
Message-ID: <Pine.LNX.4.64.0804141240260.7699@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com> <20080404230229.169327879@sgi.com>
 <20080407231346.8a17d27d.akpm@linux-foundation.org>
 <20080413133929.GA21007@martell.zuzino.mipt.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Applying Pekka's patch does not fix it? Looks like the another case of the 
missing slab_lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
