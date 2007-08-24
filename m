Received: by rv-out-0910.google.com with SMTP id l15so693701rvb
        for <linux-mm@kvack.org>; Fri, 24 Aug 2007 12:35:02 -0700 (PDT)
Message-ID: <38b2ab8a0708241235y7cc0bfefk65bd743c7ed03a6f@mail.gmail.com>
Date: Fri, 24 Aug 2007 21:35:02 +0200
From: "Francis Moreau" <francis.moro@gmail.com>
Subject: Re: pte_none versus pte_present
In-Reply-To: <Pine.LNX.4.64.0708241137180.13431@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <38b2ab8a0708240202o6570cf55j2d97e45663d8165e@mail.gmail.com>
	 <Pine.LNX.4.64.0708241137180.13431@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Hugh,

On 8/24/07, Hugh Dickins <hugh@veritas.com> wrote:
> pte_present says if there's a real page table entry there (including
> the exceptional case of a pte which is not-present to the MMU, but
> otherwise a good pte: sometimes required when handling PROT_NONE).
>

It could had been called pte_mmu instead...

> pte_none says if the slot is empty: when a pte is not present, we may
> use its slot to note where to find the page when it's to be faulted
> in; or if that's not needed leave it empty as pte_none.
>

ok, so this one could had been named pte_inuse...

> The common case of !pte_present && !pte_none is when an anonymous page
> is swapped out: the slot notes where the required page can be found
> on swap.  Oddly we don't have a macro for that case, but for the less
> common case of pte_file: used in a VM_NONLINEAR vma, to note what
> offset of the file to pull the page from when faulting in.  (And
> page migration uses a swap-like value, without actually using swap.)
>
> Hope that helps you to decide which one you need.
>

I think I get the idea now.

Thanks a lot for that !
-- 
Francis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
