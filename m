Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id A51086B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 01:11:54 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so14863332pbb.23
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 22:11:54 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id x3si13577998pbk.293.2014.02.16.22.11.51
        for <linux-mm@kvack.org>;
        Sun, 16 Feb 2014 22:11:53 -0800 (PST)
Date: Mon, 17 Feb 2014 15:12:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 9/9] slab: remove a useless lockdep annotation
Message-ID: <20140217061201.GA3468@lge.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1392361043-22420-10-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.10.1402141248560.12887@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402141248560.12887@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 14, 2014 at 12:49:57PM -0600, Christoph Lameter wrote:
> On Fri, 14 Feb 2014, Joonsoo Kim wrote:
> 
> > @@ -921,7 +784,7 @@ static int transfer_objects(struct array_cache *to,
> >  static inline struct alien_cache **alloc_alien_cache(int node,
> >  						int limit, gfp_t gfp)
> >  {
> > -	return (struct alien_cache **)BAD_ALIEN_MAGIC;
> > +	return NULL;
> >  }
> >
> 
> Why change the BAD_ALIEN_MAGIC?

Hello, Christoph.

BAD_ALIEN_MAGIC is only checked by slab_set_lock_classes(). We remove this
function in this patch, so returning BAD_ALIEN_MAGIC is useless.
And, in fact, BAD_ALIEN_MAGIC is already useless, because alloc_alien_cache()
can't be called on !CONFIG_NUMA. This function is called if use_alien_caches
is positive, but on !CONFIG_NUMA, use_alien_caches is always 0. So we don't
have any chance to meet this BAD_ALIEN_MAGIC in runtime.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
