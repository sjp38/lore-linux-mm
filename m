Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0776B006E
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 16:26:45 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so69862497pdb.1
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 13:26:45 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id o6si18180030pap.60.2015.04.08.13.26.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 13:26:43 -0700 (PDT)
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 07979208A9
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 16:26:37 -0400 (EDT)
Date: Wed, 8 Apr 2015 22:26:38 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/3 @stable] mm(v4.0): New pfn_mkwrite same as
 page_mkwrite for VM_PFNMAP
Message-ID: <20150408202638.GB10865@kroah.com>
References: <55239645.9000507@plexistor.com>
 <55254FC4.3050206@plexistor.com>
 <552550A5.6040503@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <552550A5.6040503@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Stable Tree <stable@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>

On Wed, Apr 08, 2015 at 07:00:37PM +0300, Boaz Harrosh wrote:
> On 04/08/2015 06:56 PM, Boaz Harrosh wrote:
> > From: Yigal Korman <yigal@plexistor.com>
> > 
> > [For Stable 4.0.X]
> > The parallel patch at 4.1-rc1 to this patch is:
> >   Subject: mm: new pfn_mkwrite same as page_mkwrite for VM_PFNMAP
> > 
> > We need this patch for the 4.0.X stable tree if the patch
> >   Subject: dax: use pfn_mkwrite to update c/mtime + freeze protection
> > 
> > Was decided to be pulled into stable since it is a dependency
> > of this patch. The file mm/memory.c was heavily changed in 4.1
> > hence this here.
> > 
> 
> I forgot to send this patch for the stables tree, 4.0 only.
> 
> Again this one is only needed if we are truing to pull
>    Subject: dax: use pfn_mkwrite to update c/mtime + freeze protection
> 
> Which has the Stable@ tag. The problem it fixes is minor and might
> be skipped if causes problems.

I can't take patches in the stable tree that are not in Linus's tree
also.  Why can't I just take a corrisponding patch that is already in
Linus's tree, why do we need something "special" here?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
