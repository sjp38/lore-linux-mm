Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A63246B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 11:37:47 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id 124so33549002pfg.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 08:37:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id p8si727232paq.179.2016.03.15.08.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Mar 2016 08:37:46 -0700 (PDT)
Date: Tue, 15 Mar 2016 08:37:44 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Page migration issue with UBIFS
Message-ID: <20160315153744.GB28522@infradead.org>
References: <56E8192B.5030008@nod.at>
 <20160315151727.GA16462@node.shutemov.name>
 <56E82B18.9040807@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E82B18.9040807@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boris Brezillon <boris.brezillon@free-electrons.com>, Maxime Ripard <maxime.ripard@free-electrons.com>, David Gstir <david@sigma-star.at>, Dave Chinner <david@fromorbit.com>, Artem Bityutskiy <dedekind1@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Kaplan <alex@nextthing.co>

On Tue, Mar 15, 2016 at 04:32:40PM +0100, Richard Weinberger wrote:
> > Or if ->page_mkwrite() was called, why the page is not dirty?
> 
> BTW: UBIFS does not implement ->migratepage(), could this be a problem?

This might be the reason.  I can't reall make sense of
buffer_migrate_page, but it seems to migrate buffer_head state to
the new page.

I'd love to know why CMA even tries to migrate pages that don't have a
->migratepage method, this seems incredibly dangerous to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
