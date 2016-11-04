Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A1876280256
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 23:46:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l124so8173871wml.4
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 20:46:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b65si2707778wmf.114.2016.11.03.20.46.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 20:46:36 -0700 (PDT)
Date: Fri, 4 Nov 2016 04:46:30 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 02/21] mm: Use vmf->address instead of of
 vmf->virtual_address
Message-ID: <20161104034630.GK24234@quack2.suse.cz>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
 <1478039794-20253-5-git-send-email-jack@suse.cz>
 <06aa01d234c0$1f85e700$5e91b500$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <06aa01d234c0$1f85e700$5e91b500$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Jan Kara' <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Ross Zwisler' <ross.zwisler@linux.intel.com>

On Wed 02-11-16 12:18:10, Hillf Danton wrote:
> On Wednesday, November 02, 2016 6:36 AM Jan Kara wrote:
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 8e8b76d11bb4..2a4ebe3c67c6 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -297,8 +297,6 @@ struct vm_fault {
> >  	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
> >  	pgoff_t pgoff;			/* Logical page offset based on vma */
> >  	unsigned long address;		/* Faulting virtual address */
> > -	void __user *virtual_address;	/* Faulting virtual address masked by
> > -					 * PAGE_MASK */
> >  	pmd_t *pmd;			/* Pointer to pmd entry matching
> >  					 * the 'address'
> >  					 */
> We have a pmd field currently?
> 
> In  [PATCH 01/20] mm: Change type of vmf->virtual_address we see
> [1] __user * gone,
> [2] no field of address added
> and doubt stray merge occurred.
> 
> btw, s:01/20:01/21: in subject line?

Sorry, I had old version of the series in the directory so things got
messed up. I'll resend the series. Thanks for having a look.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
