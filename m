Date: Fri, 16 Nov 2007 13:37:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Patch] mm/sparse.c: Check the return value of
 sparse_index_alloc().
Message-Id: <20071116133714.876f5246.akpm@linux-foundation.org>
In-Reply-To: <20071115135428.GE2489@hacking>
References: <20071115135428.GE2489@hacking>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: WANG Cong <xiyou.wangcong@gmail.com>
Cc: linux-kernel@vger.kernel.org, riel@redhat.com, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Nov 2007 21:54:28 +0800
WANG Cong <xiyou.wangcong@gmail.com> wrote:

> 
> Since sparse_index_alloc() can return NULL on memory allocation failure,
> we must deal with the failure condition when calling it.
> 
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
> Cc: Christoph Lameter <clameter@sgi.com>
> Cc: Rik van Riel <riel@redhat.com>
> 
> ---
> 
> diff --git a/Makefile b/Makefile
> diff --git a/mm/sparse.c b/mm/sparse.c
> index e06f514..d245e59 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -83,6 +83,8 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  		return -EEXIST;
>  
>  	section = sparse_index_alloc(nid);
> +	if (!section)
> +		return -ENOMEM;
>  	/*
>  	 * This lock keeps two different sections from
>  	 * reallocating for the same index

Sure, but both callers of sparse_index_init() ignore its return value anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
