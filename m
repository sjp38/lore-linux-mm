Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B882E6B0253
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:44:39 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id i187so7565434lfe.4
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 02:44:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n18si41186717wjq.193.2016.10.18.02.44.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 02:44:38 -0700 (PDT)
Date: Tue, 18 Oct 2016 11:44:36 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 09/20] mm: Factor out functionality to finish page faults
Message-ID: <20161018094436.GL3359@quack2.suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-10-git-send-email-jack@suse.cz>
 <20161017174042.GB6104@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161017174042.GB6104@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon 17-10-16 11:40:42, Ross Zwisler wrote:
> On Tue, Sep 27, 2016 at 06:08:13PM +0200, Jan Kara wrote:
> > +	/* Did we COW the page? */
> > +	if (vmf->flags & FAULT_FLAG_WRITE && !(vmf->vma->vm_flags & VM_SHARED))
> 
> Oh, sorry, I did have one bit of feedback.  Maybe added parens around the flag
> check for readability:
> 
> 	if ((vmf->flags & FAULT_FLAG_WRITE) && !(vmf->vma->vm_flags & VM_SHARED))

Fixed.

> Aside from that one nit:
> 
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Thanks!

								Honza 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
