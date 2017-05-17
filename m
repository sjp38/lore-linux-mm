Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C57866B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 14:23:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e8so14829623pfl.4
        for <linux-mm@kvack.org>; Wed, 17 May 2017 11:23:11 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m3si2745074pld.61.2017.05.17.11.23.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 11:23:10 -0700 (PDT)
Date: Wed, 17 May 2017 12:23:09 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/2] mm: avoid spurious 'bad pmd' warning messages
Message-ID: <20170517182309.GA30704@linux.intel.com>
References: <20170517171639.14501-1-ross.zwisler@linux.intel.com>
 <9c45c769-2f5e-9327-c39e-1df7744fa633@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9c45c769-2f5e-9327-c39e-1df7744fa633@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pawel Lebioda <pawel.lebioda@intel.com>, Dave Jiang <dave.jiang@intel.com>, Xiong Zhou <xzhou@redhat.com>, Eryu Guan <eguan@redhat.com>, stable@vger.kernel.org

On Wed, May 17, 2017 at 10:33:58AM -0700, Dave Hansen wrote:
> On 05/17/2017 10:16 AM, Ross Zwisler wrote:
> > @@ -3061,7 +3061,7 @@ static int pte_alloc_one_map(struct vm_fault *vmf)
> >  	 * through an atomic read in C, which is what pmd_trans_unstable()
> >  	 * provides.
> >  	 */
> > -	if (pmd_trans_unstable(vmf->pmd) || pmd_devmap(*vmf->pmd))
> > +	if (pmd_devmap(*vmf->pmd) || pmd_trans_unstable(vmf->pmd))
> >  		return VM_FAULT_NOPAGE;
> 
> I'm worried we are very unlikely to get this right in the future.  It's
> totally not obvious what the ordering requirement is here.
> 
> Could we move pmd_devmap() and pmd_trans_unstable() into a helper that
> gets the ordering right and also spells out the ordering requirement?

Sure, I'll fix this for v2.

Thanks for the review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
