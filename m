From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] Swap delay accounting, include lock_page() delays
Date: Wed, 31 Oct 2007 18:41:53 +1100
References: <20071031075243.22225.53636.sendpatchset@balbir-laptop>
In-Reply-To: <20071031075243.22225.53636.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710311841.53671.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM Mailing List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 31 October 2007 18:52, Balbir Singh wrote:
> Reported-by: Nick Piggin <nickpiggin@yahoo.com.au>
>
> The delay incurred in lock_page() should also be accounted in swap delay
> accounting
>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Ah right, I forgot to resend this one, sorry. Thanks for remembering.


> ---
>
>  mm/memory.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff -puN mm/swapfile.c~fix-delay-accounting-swap-accounting mm/swapfile.c
> diff -puN mm/memory.c~fix-delay-accounting-swap-accounting mm/memory.c
> ---
> linux-2.6-latest/mm/memory.c~fix-delay-accounting-swap-accounting	2007-10-3
>1 12:58:05.000000000 +0530 +++
> linux-2.6-latest-balbir/mm/memory.c	2007-10-31 13:02:50.000000000 +0530 @@
> -2084,9 +2084,9 @@ static int do_swap_page(struct mm_struct
>  		count_vm_event(PGMAJFAULT);
>  	}
>
> -	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
>  	mark_page_accessed(page);
>  	lock_page(page);
> +	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
>
>  	/*
>  	 * Back out if somebody else already faulted in this pte.
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
