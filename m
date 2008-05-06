Date: Tue, 6 May 2008 07:27:49 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 2/4] mspec: convert nopfn to fault
Message-ID: <20080506122749.GH19717@sgi.com>
References: <20080502031903.GD11844@wotan.suse.de> <20080502032132.GF11844@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080502032132.GF11844@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, jk@ozlabs.org, jes@trained-monkey.org, cpw@sgi.com
List-ID: <linux-mm.kvack.org>

Sorry, I missed this original post.  Saw the add this morning and went
back to the archives.

> -static unsigned long
> -mspec_nopfn(struct vm_area_struct *vma, unsigned long address)
> +static int
> +mspec_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
>  	unsigned long paddr, maddr;
>  	unsigned long pfn;
> +	pgoff_t index = vmf->pgoff;
>  	int index;

I think this will cause problems.  Two definitions of index.  I removed
the int index and tested.  This appears to work fine.  Sorry for the
delay.

Thanks,
Robin

Index: remove_nopfn/drivers/char/mspec.c
===================================================================
--- remove_nopfn.orig/drivers/char/mspec.c	2008-05-06 07:07:30.000000000 -0500
+++ remove_nopfn/drivers/char/mspec.c	2008-05-06 07:17:01.784314587 -0500
@@ -203,7 +203,6 @@ mspec_fault(struct vm_area_struct *vma, 
 	unsigned long paddr, maddr;
 	unsigned long pfn;
 	pgoff_t index = vmf->pgoff;
-	int index;
 	struct vma_data *vdata = vma->vm_private_data;
 
 	maddr = (volatile unsigned long) vdata->maddr[index];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
