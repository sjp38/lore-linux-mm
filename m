Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8EC6B0037
	for <linux-mm@kvack.org>; Sun, 31 Aug 2014 20:18:46 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id fp1so4696351pdb.26
        for <linux-mm@kvack.org>; Sun, 31 Aug 2014 17:18:45 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id qf4si10496215pbb.163.2014.08.31.17.18.43
        for <linux-mm@kvack.org>;
        Sun, 31 Aug 2014 17:18:45 -0700 (PDT)
Date: Mon, 1 Sep 2014 09:19:12 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] mm/slab: use percpu allocator for cpu cache
Message-ID: <20140901001912.GD25599@js1304-P5Q-DELUXE>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.11.1408271827010.26560@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1408271827010.26560@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 27, 2014 at 06:37:33PM -0500, Christoph Lameter wrote:
> One minor nit. Otherwise
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> 
> On Thu, 21 Aug 2014, Joonsoo Kim wrote:
> 
> > @@ -2041,56 +1982,63 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
> >  	return left_over;
> >  }
> >
> > +static int alloc_kmem_cache_cpus(struct kmem_cache *cachep, int entries,
> > +				int batchcount)
> > +{
> > +	cachep->cpu_cache = __alloc_kmem_cache_cpus(cachep, entries,
> > +							batchcount);
> > +	if (!cachep->cpu_cache)
> > +		return 1;
> > +
> > +	return 0;
> > +}
> 
> Do we really need this trivial function? It doesnt do anything useful as
> far as I can tell.

Hello,

You are right. I will remove it in next spin.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
