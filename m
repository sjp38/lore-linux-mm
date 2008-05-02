From: Jeremy Kerr <jk@ozlabs.org>
Subject: Re: [patch 3/4] spufs: convert nopfn to fault
Date: Fri, 2 May 2008 16:45:44 +1000
References: <20080502031903.GD11844@wotan.suse.de> <200805021406.38980.jk@ozlabs.org> <20080502050632.GJ11844@wotan.suse.de>
In-Reply-To: <20080502050632.GJ11844@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200805021645.45165.jk@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, jes@trained-monkey.org, cpw@sgi.com
List-ID: <linux-mm.kvack.org>

Hi Nick,

> -static unsigned long spufs_mem_mmap_nopfn(struct vm_area_struct
> *vma, -					  unsigned long address)
> +static int
> +spufs_mem_mmap_fault(struct vm_area_struct *vma, struct vm_fault
> *vmf) {
>  	struct spu_context *ctx	= vma->vm_file->private_data;
> -	unsigned long pfn, offset, addr0 = address;
> +	unsigned long pfn, offset, address;
> +
> +	address = (unsigned long)vmf->virtual_address;
> +
>  #ifdef CONFIG_SPU_FS_64K_LS
>  	struct spu_state *csa = &ctx->csa;
>  	int psize;

This will add a warning (you're "mixing declarations and code") if 
CONFIG_SPU_FS_64K_LS.

Cheers,


Jeremy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
