Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7070B6B025E
	for <linux-mm@kvack.org>; Tue, 17 May 2016 05:11:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 203so20341858pfy.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 02:11:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id z6si3358594paa.60.2016.05.17.02.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 02:11:37 -0700 (PDT)
Date: Tue, 17 May 2016 02:11:33 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: UBIFS and page migration (take 3)
Message-ID: <20160517091133.GA23943@infradead.org>
References: <1462974823-3168-1-git-send-email-richard@nod.at>
 <20160512114948.GA25113@infradead.org>
 <5739C0C1.1090907@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5739C0C1.1090907@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, kirill.shutemov@linux.intel.com, hughd@google.com, mgorman@techsingularity.net, vbabka@suse.cz

On Mon, May 16, 2016 at 02:44:49PM +0200, Richard Weinberger wrote:
> Is this a Reviewed-by? :-)

I don't know the code well enough to feel qualified for a review.  But
you get my:

Acked-by: Christoph Hellwig <hch@lst.de>

> There are two classes of issues:
> a) filesystems that use buffer_migrate_page() but shouldn't
> b) filesystems that don't implement ->migratepage() and fallback_migrate_page()
>    is not suitable.
> 
> As starter we could kill the automatic assignment of fallback_migrate_page() and
> non-buffer_head filesystems need to figure out whether fallback_migrate_page()
> is suitable or not.
> UBIFS found out the hard way. ;-\

Yes, I think this would be a good start.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
