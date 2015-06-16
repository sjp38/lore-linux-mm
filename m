Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8AAE66B0032
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 17:51:11 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so20521631pac.2
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 14:51:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tu7si3003564pbc.214.2015.06.16.14.51.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 14:51:10 -0700 (PDT)
Date: Tue, 16 Jun 2015 14:51:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/7] slub: fix error path bug in kmem_cache_alloc_bulk
Message-Id: <20150616145109.5bbe850094519072d33e9047@linux-foundation.org>
In-Reply-To: <20150615155226.18824.99.stgit@devil>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155226.18824.99.stgit@devil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>

On Mon, 15 Jun 2015 17:52:26 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> The current kmem_cache/SLAB bulking API need to release all objects
> in case the layer cannot satisfy the full request.
> 
> If __kmem_cache_alloc_bulk() fails, all allocated objects in array
> should be freed, but, __kmem_cache_alloc_bulk() can't know
> about objects allocated by this slub specific kmem_cache_alloc_bulk()
> function.

Can we fold patches 2, 3 and 4 into a single patch?

And maybe patch 5 as well.  I don't think we need all these
development-time increments in the permanent record.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
