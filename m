Subject: Re: [patch 2/6] CONFIG_HIGHPTE vs. sub-page page tables.
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <20071025181901.212545095@de.ibm.com>
References: <20071025181520.880272069@de.ibm.com>
	 <20071025181901.212545095@de.ibm.com>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 06:47:00 +1000
Message-Id: <1193345221.7018.18.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com
List-ID: <linux-mm.kvack.org>

> Solution: The only solution I found to this dilemma is a new typedef:
> a pgtable_t. For s390 pgtable_t will be a (pte *) - to be introduced
> with a later patch. For everybody else it will be a (struct page *).
> The additional problem with the initialization of the ptl lock and the
> NR_PAGETABLE accounting is solved with a constructor pgtable_page_ctor
> and a destructor pgtable_page_dtor. The page table allocation and free
> functions need to call these two whenever a page table page is allocated
> or freed. pmd_populate will get a pgtable_t instead of a struct page
> pointer. To get the pgtable_t back from a pmd entry that has been
> installed with pmd_populate a new function pmd_pgtable is added. It
> replaces the pmd_page call in free_pte_range and apply_to_pte_range.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> ---

Interesting. That means I don't need to have a PTE page to be a struct
page anymore ? I can have good use for that on powerpc as well... 

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
