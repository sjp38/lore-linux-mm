Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 932956B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 05:26:03 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id d7so1119687wre.15
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 02:26:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d43sor17233287eda.22.2017.12.27.02.26.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Dec 2017 02:26:02 -0800 (PST)
Date: Wed, 27 Dec 2017 13:26:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v5 06/78] xarray: Change definition of sibling entries
Message-ID: <20171227102600.vruihaqugwxa25sp@node.shutemov.name>
References: <20171215220450.7899-1-willy@infradead.org>
 <20171215220450.7899-7-willy@infradead.org>
 <20171226172153.pylgdefajcrthe3b@node.shutemov.name>
 <20171227031326.GB24828@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171227031326.GB24828@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

On Tue, Dec 26, 2017 at 07:13:26PM -0800, Matthew Wilcox wrote:
> On Tue, Dec 26, 2017 at 08:21:53PM +0300, Kirill A. Shutemov wrote:
> > > +/**
> > > + * xa_is_internal() - Is the entry an internal entry?
> > > + * @entry: Entry retrieved from the XArray
> > > + *
> > > + * Return: %true if the entry is an internal entry.
> > > + */
> > 
> > What does it mean "internal entry"? Is it just a term for non-value and
> > non-data pointer entry? Do we allow anybody besides xarray implementation to
> > use internal entires?
> > 
> > Do we have it documented?
> 
> We do!  include/linux/radix-tree.h has it documented right now:

Looks good. Thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
