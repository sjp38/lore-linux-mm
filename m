Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2DF6B000E
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 11:18:57 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id o132so3810087iod.11
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 08:18:57 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id r2si8038127ioa.113.2018.04.07.08.18.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Apr 2018 08:18:56 -0700 (PDT)
Date: Sat, 7 Apr 2018 10:18:54 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 23/25] slub: make struct kmem_cache_order_objects::x
 unsigned int
In-Reply-To: <20180406180220.GA32149@avx2>
Message-ID: <alpine.DEB.2.20.1804071013200.10800@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com> <20180305200730.15812-23-adobriyan@gmail.com> <alpine.DEB.2.20.1803061248540.29393@nuc-kabylake> <20180405145108.e1a9f788bea329653505cadc@linux-foundation.org> <20180406180220.GA32149@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Fri, 6 Apr 2018, Alexey Dobriyan wrote:

> > > I think both order and # object should fit in a 32 bit number.
> > >
> > > A page with 256M size and 4 byte objects would have 64M objects.
> >
> > Another dangling review comment.  Alexey, please respond?
>
> PowerPC is 256KB, IA64 is 64KB.

The page sizes on both platforms are configurable and there have been
experiments in the past with far larger page sizes. If this is what is
currently supported then its ok.
