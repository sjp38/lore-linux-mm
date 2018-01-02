Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0B96B02B2
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 09:53:37 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w125so33804872itf.0
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 06:53:37 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id p127si5941381iop.174.2018.01.02.06.53.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jan 2018 06:53:36 -0800 (PST)
Date: Tue, 2 Jan 2018 08:53:34 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 2/8] slub: Add defrag_ratio field and sysfs support
In-Reply-To: <20171230062052.GB27959@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1801020852310.14141@nuc-kabylake>
References: <20171227220636.361857279@linux.com> <20171227220652.322991754@linux.com> <20171230062052.GB27959@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

On Fri, 29 Dec 2017, Matthew Wilcox wrote:

> >  What:		/sys/kernel/slab/cache/deactivate_to_tail
> >  Date:		February 2008
> >  KernelVersion:	2.6.25
>
> Should this documentation mention it's SLUB-only?

It could but /sys/kernel/slab is only supported for SLUB at this point.
Sysfs handling should move into slab_common.c though long terms so that it
works for any allocator.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
