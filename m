Date: Sun, 26 Oct 2008 23:50:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/3] swap: refactor pagevec flushing
Message-Id: <20081026235011.8af44857.akpm@linux-foundation.org>
In-Reply-To: <20081022225512.879260477@saeurebad.de>
References: <20081022225006.010250557@saeurebad.de>
	<20081022225512.879260477@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Oct 2008 00:50:08 +0200 Johannes Weiner <hannes@saeurebad.de> wrote:

> Having all pagevecs in one array allows for easier flushing.  Use a
> single flush function that decides what to do based on the target LRU.
> 
> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
> ---
>  include/linux/pagevec.h |   13 +++--
>  mm/swap.c               |  121 +++++++++++++++++++++++-------------------------
>  2 files changed, 66 insertions(+), 68 deletions(-)
> 
> --- a/include/linux/pagevec.h
> +++ b/include/linux/pagevec.h
> @@ -27,10 +27,13 @@ enum lru_pagevec {
>  	NR_LRU_PAGEVECS
>  };
>  
> +#define for_each_lru_pagevec(pv)		\
> +	for (pv = 0; pv < NR_LRU_PAGEVECS; pv++)

This only gets used once.  I don't think it's existence is justified?

(`pv' is usally parenthesised in macros like this, but it's unlikely to
matter).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
