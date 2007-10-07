Date: Sun, 7 Oct 2007 19:23:42 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 4/7] shmem: SGP_QUICK and SGP_FAULT redundant
Message-ID: <20071007192342.51133d66@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0710062143420.16223@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0710062143420.16223@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Oct 2007 21:45:12 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> Remove SGP_QUICK from the sgp_type enum: it was for shmem_populate and
> has no users now.  Remove SGP_FAULT from the enum: SGP_CACHE does just
> as well (and shmem_getpage is about to return with page always
> locked).
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
