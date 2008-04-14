Received: by fg-out-1718.google.com with SMTP id e12so1632470fga.4
        for <linux-mm@kvack.org>; Mon, 14 Apr 2008 13:17:17 -0700 (PDT)
Date: Tue, 15 Apr 2008 00:12:47 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: RIP __kmem_cache_shrink (was Re: [patch 15/18] FS: Proc
	filesystem support for slab defrag)
Message-ID: <20080414201247.GA4763@martell.zuzino.mipt.ru>
References: <20080404230158.365359425@sgi.com> <20080404230229.169327879@sgi.com> <20080407231346.8a17d27d.akpm@linux-foundation.org> <20080413133929.GA21007@martell.zuzino.mipt.ru> <Pine.LNX.4.64.0804141240260.7699@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804141240260.7699@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 14, 2008 at 12:41:11PM -0700, Christoph Lameter wrote:
> Applying Pekka's patch does not fix it? Looks like the another case of the 
> missing slab_lock.

Sadly, no. Oops remains the same.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
