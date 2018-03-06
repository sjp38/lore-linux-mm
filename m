Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1812F6B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 09:13:26 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id s25so11601923pfh.9
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 06:13:26 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q188si9920007pga.547.2018.03.06.06.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Mar 2018 06:13:25 -0800 (PST)
Date: Tue, 6 Mar 2018 06:13:17 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/7] genalloc: track beginning of allocations
Message-ID: <20180306141317.GC13722@bombadil.infradead.org>
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-2-igor.stoppa@huawei.com>
 <20180306131856.GD19349@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180306131856.GD19349@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, Mar 06, 2018 at 02:19:03PM +0100, Mike Rapoport wrote:
> > +/**
> > + * gen_pool_create() - create a new special memory pool
> > + * @min_alloc_order: log base 2 of number of bytes each bitmap entry
> > + *		     represents
> > + * @nid: node id of the node the pool structure should be allocated on,
> > + *	 or -1
> > + *
> > + * Create a new special memory pool that can be used to manage special
> > + * purpose memory not managed by the regular kmalloc/kfree interface.
> > + *
> > + * Return:
> > + * * pointer to the pool	- success
> > + * * NULL			- otherwise
> > + */
> 
> If I'm not mistaken, several kernel-doc descriptions are duplicated now.
> Can you please keep a single copy? ;-)

I think the problem is that Igor has chosen to put the kernel-doc with
the function declaration.  I think we usually recommend putting it with
the definition so it's more likely to be updated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
