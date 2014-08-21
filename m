Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2170C6B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 10:21:34 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so14550278pab.16
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 07:21:33 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTPS id zr1si36565589pbc.36.2014.08.21.07.21.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 07:21:33 -0700 (PDT)
Date: Thu, 21 Aug 2014 09:21:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm/slab: use percpu allocator for cpu cache
In-Reply-To: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1408210918050.32524@gentwo.org>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>, linux-kernel@vger.kernel.org

On Thu, 21 Aug 2014, Joonsoo Kim wrote:

> So, this patch try to use percpu allocator in SLAB. This simplify
> initialization step in SLAB so that we could maintain SLAB code more
> easily.

I thought about this a couple of times but the amount of memory used for
the per cpu arrays can be huge. In contrast to slub which needs just a
few pointers, slab requires one pointer per object that can be in the
local cache. CC Tj.

Lets say we have 300 caches and we allow 1000 objects to be cached per
cpu. That is 300k pointers per cpu. 1.2M on 32 bit. 2.4M per cpu on
64bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
