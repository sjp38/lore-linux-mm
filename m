From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200010302139.NAA97387@google.engr.sgi.com>
Subject: Re: [PATCH] 2.4.0-test10-pre6  TLB flush race in establish_pte
Date: Mon, 30 Oct 2000 13:39:31 -0800 (PST)
In-Reply-To: <OFB4731A18.0D8D8BC1-ON85256988.0074562B@raleigh.ibm.com> from "Steve Pratt/Austin/IBM" at Oct 30, 2000 03:31:22 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Pratt/Austin/IBM <slpratt@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> So while there may be a more elegant solution down the road, I would like
> to see the simple fix put back into 2.4.  Here is the patch to essential
> put the code back to the way it was before the S/390 merge.  Patch is
> against 2.4.0-test10pre6.
> 
> --- linux/mm/memory.c    Fri Oct 27 15:26:14 2000
> +++ linux-2.4.0-test10patch/mm/memory.c  Fri Oct 27 15:45:54 2000
> @@ -781,8 +781,8 @@
>   */
>  static inline void establish_pte(struct vm_area_struct * vma, unsigned long address, pte_t *page_table, pte_t entry)
>  {
> -    flush_tlb_page(vma, address);
>      set_pte(page_table, entry);
> +    flush_tlb_page(vma, address);
>      update_mmu_cache(vma, address, entry);
>  }
>

Great, lets do it. Definitely solves one race. 

Kanoj 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
