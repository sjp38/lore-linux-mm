Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7CC6B0033
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 19:19:18 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id z142so24900130itc.6
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 16:19:18 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id f11si17474317ite.9.2017.12.28.16.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Dec 2017 16:19:17 -0800 (PST)
Date: Thu, 28 Dec 2017 18:19:15 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 0/8] Xarray object migration V1
In-Reply-To: <20171228222419.GQ1871@rh>
Message-ID: <alpine.DEB.2.20.1712281803130.26478@nuc-kabylake>
References: <20171227220636.361857279@linux.com> <20171228222419.GQ1871@rh>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@lst.de>

On Fri, 29 Dec 2017, Dave Chinner wrote:

> IOWs, just saying "it would be worthwhile to extend this to dentries
> and inodes" completely misrepresents the sheer complexity of doing
> so. We've known that atomic replacement is the big problem for
> defragging inodes and dentries since this work was started, what,
> more than 10 years? And while there's been many revisions of the
> core defrag code since then, there has been no credible solution
> presented for atomic replacement of objects with complex external
> references. This is a show-stopper for inode/dentry slab defrag, and
> I don't see that this new patchset is any different...

Well this is a chance here to start an implementation since the radix tree
is being reworked anyways. This is not dealing with dentries and inodes
but it brings in the basic infrastructure into the slab allocators that
can then be used to add other slab caches. Same warnings were given to me
when we did page migration and it languished for 5 years.

I have not had time to really focus on memory management issues since I
left SGI about 9 years ago but it seems that I may now have the chance in
2018 to put a significant amount of time into making some progress.

Large memory in servers has become a significant problem for my employer
and the ability to allocate and manage contiguous memory blocks is
essential to preserve performance and avoid constant reboot. So I will be
looking for ways to address these issues. Maybe with a couple of
approaches.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
