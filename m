Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id D385B6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 19:28:02 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f12so316843qad.10
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 16:28:02 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id e9si4034359qgf.109.2015.01.23.16.28.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 16:28:02 -0800 (PST)
Date: Fri, 23 Jan 2015 18:28:00 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/3] Slab allocator array operations
In-Reply-To: <20150123145734.aa3c6c6e7432bc3534f2c4cc@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1501231827330.10083@gentwo.org>
References: <20150123213727.142554068@linux.com> <20150123145734.aa3c6c6e7432bc3534f2c4cc@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, 23 Jan 2015, Andrew Morton wrote:

> On Fri, 23 Jan 2015 15:37:27 -0600 Christoph Lameter <cl@linux.com> wrote:
>
> > Attached a series of 3 patches to implement functionality to allocate
> > arrays of pointers to slab objects. This can be used by the slab
> > allocators to offer more optimized allocation and free paths.
>
> What's the driver for this?  The networking people, I think?  If so,
> some discussion about that would be useful: who is involved, why they
> have this need, who are the people we need to bug to get it tested,
> whether this implementation is found adequate, etc.

Jesper and I gave a talk at LCA about this. LWN has an article on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
