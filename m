Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id A02066B0035
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 00:09:19 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id 29so411024yhl.19
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 21:09:19 -0800 (PST)
Received: from mail-yh0-x22f.google.com (mail-yh0-x22f.google.com [2607:f8b0:4002:c01::22f])
        by mx.google.com with ESMTPS id s22si3610000yha.76.2014.01.14.21.09.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 21:09:18 -0800 (PST)
Received: by mail-yh0-f47.google.com with SMTP id c41so405632yho.20
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 21:09:18 -0800 (PST)
Date: Tue, 14 Jan 2014 21:09:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 5/5] slab: make more slab management structure off
 the slab
In-Reply-To: <1385974183-31423-6-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1401142109050.7751@chino.kir.corp.google.com>
References: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com> <1385974183-31423-6-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Mon, 2 Dec 2013, Joonsoo Kim wrote:

> Now, the size of the freelist for the slab management diminish,
> so that the on-slab management structure can waste large space
> if the object of the slab is large.
> 
> Consider a 128 byte sized slab. If on-slab is used, 31 objects can be
> in the slab. The size of the freelist for this case would be 31 bytes
> so that 97 bytes, that is, more than 75% of object size, are wasted.
> 
> In a 64 byte sized slab case, no space is wasted if we use on-slab.
> So set off-slab determining constraint to 128 bytes.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
