Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id C001C6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 11:16:08 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id w8so2826579qac.19
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 08:16:08 -0700 (PDT)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id i10si17754538qgd.66.2014.06.02.08.16.07
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 08:16:08 -0700 (PDT)
Date: Mon, 2 Jun 2014 10:16:03 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 5/8] slab: remove kmem_cache_shrink retval
In-Reply-To: <20140531102740.GB25076@esperanza>
Message-ID: <alpine.DEB.2.10.1406021014140.2987@gentwo.org>
References: <cover.1401457502.git.vdavydov@parallels.com> <d2bbd28ae0f0c1807f9fe72d0443eccb739b8aa6.1401457502.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405300947170.11943@gentwo.org> <20140531102740.GB25076@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 31 May 2014, Vladimir Davydov wrote:

> > Well slub returns an error code if it fails
>
> ... to sort slabs by the nubmer of objects in use, which is not even
> implied by the function declaration. Why can *shrinking*, which is what
> kmem_cache_shrink must do at first place, ever fail?

Because there is a memory allocation failure. Or there may be other
processes going on that prevent shrinking. F.e. We may want to merge a
patchset that does defragmentation of slabs at some point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
