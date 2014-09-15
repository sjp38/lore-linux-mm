Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id F07946B0035
	for <linux-mm@kvack.org>; Sun, 14 Sep 2014 21:49:41 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so5071290pdb.11
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 18:49:41 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id gz10si13447124pbc.45.2014.09.14.18.49.39
        for <linux-mm@kvack.org>;
        Sun, 14 Sep 2014 18:49:40 -0700 (PDT)
Date: Mon, 15 Sep 2014 10:49:39 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH -mmotm] mm: fix kmemcheck.c build errors
Message-ID: <20140915014939.GB2676@js1304-P5Q-DELUXE>
References: <1409902086-32311-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140905130102.f6b8866115f83a0bacedb899@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140905130102.f6b8866115f83a0bacedb899@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, Pekka Enberg <penberg@kernel.org>, Vegard Nossum <vegardno@ifi.uio.no>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Randy Dunlap <rdunlap@infradead.org>

On Fri, Sep 05, 2014 at 01:01:02PM -0700, Andrew Morton wrote:
> On Fri,  5 Sep 2014 16:28:06 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > mm-slab_common-move-kmem_cache-definition-to-internal-header.patch
> > in mmotm makes following build failure.
> > 
> > ../mm/kmemcheck.c:70:7: error: dereferencing pointer to incomplete type
> > ../mm/kmemcheck.c:83:15: error: dereferencing pointer to incomplete type
> > ../mm/kmemcheck.c:95:8: error: dereferencing pointer to incomplete type
> > ../mm/kmemcheck.c:95:21: error: dereferencing pointer to incomplete type
> > 
> > ../mm/slab.h: In function 'cache_from_obj':
> > ../mm/slab.h:283:2: error: implicit declaration of function
> > 'memcg_kmem_enabled' [-Werror=implicit-function-declaration]
> > 
> > Add header files to fix kmemcheck.c build errors.
> > 
> > [iamjoonsoo.kim@lge.com] move up memcontrol.h header
> > to fix build failure if CONFIG_MEMCG_KMEM=y too.
> 
> Looking at this line
> 
> > Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> 
> and at this line
> 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> I am suspecting that this patch was authored by Randy.  But there was
> no From: line at start-of-changelog to communicate this?
> 
> > diff --git a/mm/slab.h b/mm/slab.h
> > index 13845d0..963a3f8 100644
> > --- a/mm/slab.h
> > +++ b/mm/slab.h
> > @@ -37,6 +37,8 @@ struct kmem_cache {
> >  #include <linux/slub_def.h>
> >  #endif
> >  
> > +#include <linux/memcontrol.h>
> > +
> >  /*
> >   * State of the slab allocator.
> >   *
> 
> It seems a bit wrong to include a fairly high-level memcontol.h into a
> fairly low-level slab.h, but I expect it will work.
> 
> I can't really see how
> mm-slab_common-move-kmem_cache-definition-to-internal-header.patch
> caused the breakage.  I don't know how you were triggering this build
> failure - please always include such info in the changelogs.

Hello,

Sorry for all mistakes.
Here goes new one having proper commit description and authorship.

------------>8------------------
