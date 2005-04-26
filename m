Date: Tue, 26 Apr 2005 03:29:42 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: VM 8/8 shrink_list(): set PG_reclaimed
Message-Id: <20050426032942.6a3c362d.akpm@osdl.org>
In-Reply-To: <17006.5376.606064.533068@gargle.gargle.HOWL>
References: <16994.40728.397980.431164@gargle.gargle.HOWL>
	<20050425212911.31cf6b43.akpm@osdl.org>
	<17006.5376.606064.533068@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
>  > 
>   > To address the race which Nick identified I think we can do it this way?
> 
>  I think that instead of fixing that race we'd better to make it valid:
>  let's redefine PG_reclaim to mean
> 
>         "page has been seen on the tail of the inactive list, but VM
>         failed to reclaim it right away either because it was dirty, or
>         there was some race. Reclaim this page as soon as possible."
> 
>  Nikita.
> 
>  set PG_reclaimed bit on pages that are under writeback when shrink_list()
>  looks at them: these pages are at end of the inactive list, and it only makes
>  sense to reclaim them as soon as possible when writeout finishes.

Seems a bit too complex to me.  See if you can get it back to a three-liner ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
