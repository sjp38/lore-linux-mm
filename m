Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B13F6B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:13:47 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id an2so1585046wjc.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 02:13:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j2si28574447wrc.129.2017.01.18.02.13.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 02:13:46 -0800 (PST)
Date: Wed, 18 Jan 2017 11:13:43 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [ATTEND] many topics
Message-ID: <20170118101343.GC24789@quack2.suse.cz>
References: <20170118054945.GD18349@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118054945.GD18349@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue 17-01-17 21:49:45, Matthew Wilcox wrote:
> 1. Exploiting multiorder radix tree entries.  I believe we would do well
> to attempt to allocate compound pages, insert them into the page cache,
> and expect filesystems to be able to handle filling compound pages with
> ->readpage.  It will be more efficient because alloc_pages() can return
> large entries out of the buddy list rather than breaking them down,
> and it'll help reduce fragmentation.

Kirill has patches to do this and I don't like the complexity it adds to
pagecache handling code and each filesystem that would like to support
this. I don't have objections to the general idea but the complexity of the
current implementation just looks too big to me...

> 2. Supporting filesystem block sizes > page size.  Once we do the above
> for efficiency, I think it then becomes trivial to support, eg 16k block
> size filesystems on x86 machines with 4k pages.

Heh, you wish... :) There's a big difference between opportunistically
allocating a huge page and reliably have to provide high order page. Memory
fragmentation issues will be difficult to deal with...
 
								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
