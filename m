Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id CB2746B0032
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 02:25:37 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so21376319qkh.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 23:25:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y184si3434220qky.75.2015.06.16.23.25.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 23:25:37 -0700 (PDT)
Date: Wed, 17 Jun 2015 08:25:31 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 4/7] slub: fix error path bug in kmem_cache_alloc_bulk
Message-ID: <20150617082531.33eb524c@redhat.com>
In-Reply-To: <20150616145109.5bbe850094519072d33e9047@linux-foundation.org>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155226.18824.99.stgit@devil>
	<20150616145109.5bbe850094519072d33e9047@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, brouer@redhat.com

On Tue, 16 Jun 2015 14:51:09 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 15 Jun 2015 17:52:26 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
> > The current kmem_cache/SLAB bulking API need to release all objects
> > in case the layer cannot satisfy the full request.
> > 
> > If __kmem_cache_alloc_bulk() fails, all allocated objects in array
> > should be freed, but, __kmem_cache_alloc_bulk() can't know
> > about objects allocated by this slub specific kmem_cache_alloc_bulk()
> > function.
> 
> Can we fold patches 2, 3 and 4 into a single patch?
> 
> And maybe patch 5 as well.  I don't think we need all these
> development-time increments in the permanent record.

I agree.  I'll fold them when submitting V2

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
