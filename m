MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16955.23669.792362.539790@cargo.ozlabs.ibm.com>
Date: Sat, 19 Mar 2005 09:55:49 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 1/4] io_remap_pfn_range: add for all arch-es
In-Reply-To: <20050318113352.0baaaf5e.rddunlap@osdl.org>
References: <20050318112545.6f5f7635.rddunlap@osdl.org>
	<20050318113352.0baaaf5e.rddunlap@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@osdl.org, davem@davemloft.net, wli@holomorphy.com, riel@redhat.com, kurt@garloff.de, Keir.Fraser@cl.cam.ac.uk, Ian.Pratt@cl.cam.ac.uk, Christian.Limpach@cl.cam.ac.uk
List-ID: <linux-mm.kvack.org>

Randy.Dunlap writes:

> diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2611-bk3-pv/include/asm-ppc/pgtable.h linux-2611-bk3-pfn/include/asm-ppc/pgtable.h
> --- linux-2611-bk3-pv/include/asm-ppc/pgtable.h	2005-03-07 11:02:18.000000000 -0800
> +++ linux-2611-bk3-pfn/include/asm-ppc/pgtable.h	2005-03-07 11:04:59.000000000 -0800
> @@ -735,11 +735,27 @@ static inline int io_remap_page_range(st
>  	phys_addr_t paddr64 = fixup_bigphys_addr(paddr, size);
>  	return remap_pfn_range(vma, vaddr, paddr64 >> PAGE_SHIFT, size, prot);
>  }
> +
> +static inline int io_remap_pfn_range(struct vm_area_struct *vma,
> +					unsigned long vaddr,
> +					unsigned long pfn,
> +					unsigned long size,
> +					pgprot_t prot)
> +{
> +	phys_addr_t paddr64 = fixup_bigphys_addr(pfn << PAGE_SHIFT, size);
> +	return remap_pfn_range(vma, vaddr, pfn, size, prot);

Just by inspection, this looks like pfn should be changed to
paddr64 >> PAGE_SHIFT in that last line.

Paul.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
