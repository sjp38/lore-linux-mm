Date: Wed, 27 Nov 2002 09:38:37 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.5.49-mm2
In-Reply-To: <3DE48C4A.98979F0C@digeo.com>
Message-ID: <Pine.LNX.4.44L.0211270930510.4103-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Nov 2002, Andrew Morton wrote:

> +pf_memdie.patch
>
>  Fix the PF_MEMDIE logic

The first part of the patch looks suspicious. If PF_MEMALLOC
is set we shouldn't be allowed to go into try_to_free_pages()
in the first place, should we ?

> +writeback-handle-memory-backed.patch
>
>  Don't try to write out memory-backed filesystems at all

Neat. Exactly the thing I was looking for for an O(1) VM
optimisation, good to know it's possible in 2.5 ;)

> simplified-vm-throttling.patch
>   Remove the final per-page throttling site in the VM
>
> page-reclaim-motion.patch
>   Move reclaimable pages to the tail ofthe inactive list on IO completion

Very nice, though if you're worried about effective reclaiming
you might be interested in Arjan's O(1) VM code, which I'll
probably forward-port to 2.5 once I've got it properly tuned.

> activate-unreleaseable-pages.patch
>   Move unreleasable pages onto the active list

Interesting, does this make much difference ?

cheers,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://guru.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
