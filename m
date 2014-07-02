Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id D5DA96B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 20:39:18 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id s7so7558120lbd.32
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 17:39:18 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id i10si21055566laf.109.2014.07.01.17.39.15
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 17:39:17 -0700 (PDT)
Date: Wed, 2 Jul 2014 09:44:26 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 3/9] slab: defer slab_destroy in free_block()
Message-ID: <20140702004426.GB9972@js1304-P5Q-DELUXE>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1404203258-8923-4-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1407011524210.4004@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407011524210.4004@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>

On Tue, Jul 01, 2014 at 03:25:04PM -0700, David Rientjes wrote:
> On Tue, 1 Jul 2014, Joonsoo Kim wrote:
> 
> > In free_block(), if freeing object makes new free slab and number of
> > free_objects exceeds free_limit, we start to destroy this new free slab
> > with holding the kmem_cache node lock. Holding the lock is useless and,
> > generally, holding a lock as least as possible is good thing. I never
> > measure performance effect of this, but we'd be better not to hold the lock
> > as much as possible.
> > 
> > Commented by Christoph:
> >   This is also good because kmem_cache_free is no longer called while
> >   holding the node lock. So we avoid one case of recursion.
> > 
> > Acked-by: Christoph Lameter <cl@linux.com>
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Not sure what happened to my
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> from http://marc.info/?l=linux-kernel&m=139951092124314, and for the 
> record, I still think the free_block() "list" formal should be commented.


Really sorry about that.
My mail client didn't have this mail due to unknow reason, so I missed it.

Here goes the new one with applying your comment.

--------->8------------
