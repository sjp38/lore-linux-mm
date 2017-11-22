Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9A886B026C
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 17:35:10 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 4so10654465wrt.8
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:35:10 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y14sor10236780ede.42.2017.11.22.14.35.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 14:35:09 -0800 (PST)
Date: Wed, 22 Nov 2017 23:35:03 +0100
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH 05/62] radix tree: Add a missing cast to gfp_t
Message-ID: <20171122223501.6qtgsyy5ixpuel4d@ltop.local>
References: <20171122210739.29916-1-willy@infradead.org>
 <20171122210739.29916-6-willy@infradead.org>
 <20171122212847.axib6ito23sldlbe@ltop.local>
 <20171122222402.GA13634@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171122222402.GA13634@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

On Wed, Nov 22, 2017 at 02:24:02PM -0800, Matthew Wilcox wrote:
> On Wed, Nov 22, 2017 at 10:28:48PM +0100, Luc Van Oostenryck wrote:
> > > -	root->gfp_mask &= (1 << ROOT_TAG_SHIFT) - 1;
> > > +	root->gfp_mask &= (__force gfp_t)((1 << ROOT_TAG_SHIFT) - 1);
> > 
> > IMO, it would be better to define something for that in radix-tree.h,
> > like it has been done for ROOT_IS_IDR.
> 
> If we were keeping the radix tree around, I'd agree, but the point of
> the rest of this patch set is replacing it ;-)  I should probably have
> just dropped this patch, to be honest.

Ah OK, sure.
I confess I didn't saw the whole series, just this patch.

-- Luc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
