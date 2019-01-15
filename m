Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 20DBB8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 16:12:29 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q63so2899384pfi.19
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:12:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c3si4067471pls.73.2019.01.15.13.12.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 Jan 2019 13:12:28 -0800 (PST)
Date: Tue, 15 Jan 2019 13:12:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
Message-ID: <20190115211207.GD6310@bombadil.infradead.org>
References: <20190115181300.27547-1-dave@stgolabs.net>
 <20190115181300.27547-7-dave@stgolabs.net>
 <20190115205311.GD22031@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190115205311.GD22031@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Davidlohr Bueso <dbueso@suse.de>

On Tue, Jan 15, 2019 at 08:53:16PM +0000, Jason Gunthorpe wrote:
> > -	new_pinned = atomic_long_read(&mm->pinned_vm) + npages;
> > +	new_pinned = atomic_long_add_return(npages, &mm->pinned_vm);
> >  	if (new_pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
> 
> I thought a patch had been made for this to use check_overflow...

That got removed again by patch 1 ...
