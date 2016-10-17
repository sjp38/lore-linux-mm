Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA0666B0253
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:09:45 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id i187so96536229lfe.4
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 02:09:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h5si15136718wjj.224.2016.10.17.02.09.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 02:09:44 -0700 (PDT)
Date: Mon, 17 Oct 2016 11:09:37 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 17/17] dax: remove "depends on BROKEN" from FS_DAX_PMD
Message-ID: <20161017090937.GG3359@quack2.suse.cz>
References: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
 <20161012225022.15507-18-ross.zwisler@linux.intel.com>
 <87eg3ftt4r.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87eg3ftt4r.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon 17-10-16 11:27:24, Aneesh Kumar K.V wrote:
> Ross Zwisler <ross.zwisler@linux.intel.com> writes:
> 
> > Now that DAX PMD faults are once again working and are now participating in
> > DAX's radix tree locking scheme, allow their config option to be enabled.
> >
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> >  fs/Kconfig | 1 -
> >  1 file changed, 1 deletion(-)
> >
> > diff --git a/fs/Kconfig b/fs/Kconfig
> > index 2bc7ad7..b6f0fce 100644
> > --- a/fs/Kconfig
> > +++ b/fs/Kconfig
> > @@ -55,7 +55,6 @@ config FS_DAX_PMD
> >  	depends on FS_DAX
> >  	depends on ZONE_DEVICE
> >  	depends on TRANSPARENT_HUGEPAGE
> > -	depends on BROKEN
> >  
> >  endif # BLOCK
> 
> 
> This series made dax_pmd_fault return VM_FAULT_FALLBACK in [PATCH v6 09/17] dax: remove dax_pmd_fault(). 
> That essentially disable dax pmd for ext4. Any plans to fix that ?

I'm working on converting ext4 to the new iomap infrastructure. Once that
is done, it can use new DAX helpers for PMD faults easily.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
