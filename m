Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 964FB6B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 05:17:22 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id o16so9713333wmf.4
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 02:17:22 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t5sor17187124edm.10.2017.12.27.02.17.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Dec 2017 02:17:20 -0800 (PST)
Date: Wed, 27 Dec 2017 13:17:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v5 03/78] xarray: Add the xa_lock to the radix_tree_root
Message-ID: <20171227101718.o7ucns4garbsm5ju@node.shutemov.name>
References: <20171215220450.7899-1-willy@infradead.org>
 <20171215220450.7899-4-willy@infradead.org>
 <20171226165440.tv6inwa2fgk3bfy6@node.shutemov.name>
 <20171227034340.GC24828@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171227034340.GC24828@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

On Tue, Dec 26, 2017 at 07:43:40PM -0800, Matthew Wilcox wrote:
> On Tue, Dec 26, 2017 at 07:54:40PM +0300, Kirill A. Shutemov wrote:
> > On Fri, Dec 15, 2017 at 02:03:35PM -0800, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > 
> > > This results in no change in structure size on 64-bit x86 as it fits in
> > > the padding between the gfp_t and the void *.
> > 
> > The patch does more than described in the subject and commit message. At first
> > I was confused why do you need to touch idr here. It took few minutes to figure
> > it out.
> > 
> > Could you please add more into commit message about lockname and xa_ locking
> > interface since you introduce it here?
> 
> Sure!  How's this?
> 
>     xarray: Add the xa_lock to the radix_tree_root
>     
>     This results in no change in structure size on 64-bit x86 as it fits in
>     the padding between the gfp_t and the void *.
>     
>     Initialising the spinlock requires a name for the benefit of lockdep,
>     so RADIX_TREE_INIT() now needs to know the name of the radix tree it's
>     initialising, and so do IDR_INIT() and IDA_INIT().
>     
>     Also add the xa_lock() and xa_unlock() family of wrappers to make it
>     easier to use the lock.  If we could rely on -fplan9-extensions in
>     the compiler, we could avoid all of this syntactic sugar, but that
>     wasn't added until gcc 4.6.
> 

Looks great, thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
