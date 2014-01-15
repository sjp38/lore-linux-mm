Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id A08986B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 00:05:54 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f11so518202qae.24
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 21:05:54 -0800 (PST)
Received: from mail-yh0-x22a.google.com (mail-yh0-x22a.google.com [2607:f8b0:4002:c01::22a])
        by mx.google.com with ESMTPS id x4si3660035qad.140.2014.01.14.21.05.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 21:05:53 -0800 (PST)
Received: by mail-yh0-f42.google.com with SMTP id z12so134355yhz.1
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 21:05:53 -0800 (PST)
Date: Tue, 14 Jan 2014 21:05:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 3/5] slab: restrict the number of objects in a slab
In-Reply-To: <1385974183-31423-4-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1401142105380.7751@chino.kir.corp.google.com>
References: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com> <1385974183-31423-4-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Mon, 2 Dec 2013, Joonsoo Kim wrote:

> To prepare to implement byte sized index for managing the freelist
> of a slab, we should restrict the number of objects in a slab to be less
> or equal to 256, since byte only represent 256 different values.
> Setting the size of object to value equal or more than newly introduced
> SLAB_OBJ_MIN_SIZE ensures that the number of objects in a slab is less or
> equal to 256 for a slab with 1 page.
> 
> If page size is rather larger than 4096, above assumption would be wrong.
> In this case, we would fall back on 2 bytes sized index.
> 
> If minimum size of kmalloc is less than 16, we use it as minimum object
> size and give up this optimization.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
