Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC716B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 00:04:43 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id j3so1341621pld.0
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 21:04:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m26sor316760pgv.400.2018.02.08.21.04.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 21:04:42 -0800 (PST)
Date: Fri, 9 Feb 2018 14:04:36 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/2] zsmalloc: introduce zs_huge_object() function
Message-ID: <20180209050436.GB689@jagdpanzerIV>
References: <20180207092919.19696-1-sergey.senozhatsky@gmail.com>
 <20180207092919.19696-2-sergey.senozhatsky@gmail.com>
 <20180208163006.GB17354@rapoport-lnx>
 <20180209025520.GA3423@jagdpanzerIV>
 <20180209041046.GB23828@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180209041046.GB23828@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/08/18 20:10), Matthew Wilcox wrote:
> > > > +/*
> > > > + * Check if the object's size falls into huge_class area. We must take
> > > > + * ZS_HANDLE_SIZE into account and test the actual size we are going to
> > > > + * use up. zs_malloc() unconditionally adds handle size before it performs
> > > > + * size_class lookup, so we may endup in a huge class yet zs_huge_object()
> > > > + * returned 'false'.
> > > > + */
> > > 
> > > Can you please reformat this comment as kernel-doc?
> > 
> > Is this - Documentation/doc-guide/kernel-doc.rst - the right thing
> > to use as a reference?
> 
> Yes.  I just sent a revision to it that makes it (I think) a little
> easier to read.  Try this version:

That's helpful, thanks! Will take a look and re-spin the patch.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
