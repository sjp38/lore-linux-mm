Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 097616B00A4
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 14:03:00 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so3163769pdj.15
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 11:03:00 -0700 (PDT)
Date: Thu, 17 Oct 2013 18:02:57 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 00/15] slab: overload struct slab over struct page to
 reduce memory usage
In-Reply-To: <525F8FA4.3000702@iki.fi>
Message-ID: <00000141c795afcd-7cd3594e-91c4-404a-9f99-48c3b7d19d6f-000000@email.amazonses.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com> <20131016133457.60fa71f893cd2962d8ec6ff3@linux-foundation.org> <525F8FA4.3000702@iki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Thu, 17 Oct 2013, Pekka Enberg wrote:

> On 10/16/13 10:34 PM, Andrew Morton wrote:
> > On Wed, 16 Oct 2013 17:43:57 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > wrote:
> >
> > > There is two main topics in this patchset. One is to reduce memory usage
> > > and the other is to change a management method of free objects of a slab.
> > >
> > > The SLAB allocate a struct slab for each slab. The size of this structure
> > > except bufctl array is 40 bytes on 64 bits machine. We can reduce memory
> > > waste and cache footprint if we overload struct slab over struct page.
> > Seems a good idea from a quick look.
>
> Indeed.
>
> Christoph, I'd like to pick this up and queue for linux-next. Any
> objections or comments to the patches?

I think this is fine. I have looked through the whole set repeatedly and
like the overall approach but I have I have only commented in detail on a
the beginning part of it. There was always something coming up. Sigh.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
