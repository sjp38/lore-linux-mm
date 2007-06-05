Date: Tue, 5 Jun 2007 16:39:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] mm: move_page_tables{,_up}
Message-Id: <20070605163920.8066af33.akpm@linux-foundation.org>
In-Reply-To: <20070605151203.738393000@chello.nl>
References: <20070605150523.786600000@chello.nl>
	<20070605151203.738393000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 05 Jun 2007 17:05:26 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Provide functions for moving page tables upwards.
> 
> ...
>
> +extern unsigned long move_page_tables(struct vm_area_struct *vma,
> +		unsigned long old_addr, struct vm_area_struct *new_vma,
> +		unsigned long new_addr, unsigned long len);
> +extern unsigned long move_page_tables_up(struct vm_area_struct *vma,
> +		unsigned long old_addr, struct vm_area_struct *new_vma,
> +		unsigned long new_addr, unsigned long len);
>  extern unsigned long do_mremap(unsigned long addr,
>  			       unsigned long old_len, unsigned long new_len,
>  			       unsigned long flags, unsigned long new_addr);

They become kernel-wide

> +static void move_ptes_up(struct vm_area_struct *vma, pmd_t *old_pmd,
> +		unsigned long old_addr, unsigned long old_end,
> +		struct vm_area_struct *new_vma, pmd_t *new_pmd,
> +		unsigned long new_addr)

So some documentation might be in order...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
