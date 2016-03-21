Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8CE6B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 11:28:49 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id 4so137374992pfd.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 08:28:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id yp3si22175797pac.120.2016.03.21.08.28.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 08:28:48 -0700 (PDT)
Date: Mon, 21 Mar 2016 08:28:45 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Page migration issue with UBIFS
Message-ID: <20160321152845.GA17864@infradead.org>
References: <56E8192B.5030008@nod.at>
 <20160315151727.GA16462@node.shutemov.name>
 <56E82B18.9040807@nod.at>
 <20160315153744.GB28522@infradead.org>
 <56E8985A.1020509@nod.at>
 <20160316142156.GA23595@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160316142156.GA23595@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Richard Weinberger <richard@nod.at>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boris Brezillon <boris.brezillon@free-electrons.com>, Maxime Ripard <maxime.ripard@free-electrons.com>, David Gstir <david@sigma-star.at>, Dave Chinner <david@fromorbit.com>, Artem Bityutskiy <dedekind1@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Kaplan <alex@nextthing.co>

On Wed, Mar 16, 2016 at 05:21:56PM +0300, Kirill A. Shutemov wrote:
> > FYI, with a dummy ->migratepage() which returns only -EINVAL UBIFS does no
> > longer explode upon page migration.
> > Tomorrow I'll do more tests to make sure.
> 
> Could you check if something like this would fix the issue.
> Completely untested.

We really need to make the default safe for file systems that don't
have a migratepage method.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
