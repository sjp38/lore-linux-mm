Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id E483082F99
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 06:40:07 -0400 (EDT)
Received: by qgx61 with SMTP id 61so90814226qgx.3
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 03:40:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z37si3589927qkg.87.2015.10.02.03.40.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 03:40:07 -0700 (PDT)
Date: Fri, 2 Oct 2015 12:40:01 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Message-ID: <20151002124001.2c1d9d7d@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1510020508580.2991@east.gentwo.org>
References: <560ABE86.9050508@gmail.com>
	<20150930114255.13505.2618.stgit@canyon>
	<20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
	<20151002114118.75aae2f9@redhat.com>
	<alpine.DEB.2.20.1510020508580.2991@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, brouer@redhat.com

On Fri, 2 Oct 2015 05:10:02 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Fri, 2 Oct 2015, Jesper Dangaard Brouer wrote:
> 
> > Thus, I need introducing new code like this patch and at the same time
> > have to reduce the number of instruction-cache misses/usage.  In this
> > case we solve the problem by kmem_cache_free_bulk() not getting called
> > too often. Thus, +17 bytes will hopefully not matter too much... but on
> > the other hand we sort-of know that calling kmem_cache_free_bulk() will
> > cause icache misses.
> 
> Can we just drop the WARN/BUG here? Nothing untoward happens if size == 0
> right?

I think we crash if size == 0, as we deref p[--size] in build_detached_freelist().


(aside note: The code do handles if pointers in the p array are NULL)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
