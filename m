Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id C0E8F6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 20:43:11 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id mc6so6524499lab.13
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 17:43:10 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id xt10si5119203lbb.21.2014.07.01.17.43.08
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 17:43:10 -0700 (PDT)
Date: Wed, 2 Jul 2014 09:48:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 5/9] slab: introduce alien_cache
Message-ID: <20140702004819.GD9972@js1304-P5Q-DELUXE>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1404203258-8923-6-git-send-email-iamjoonsoo.kim@lge.com>
 <20140701151547.fa67354878399575c8eb4647@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140701151547.fa67354878399575c8eb4647@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>

On Tue, Jul 01, 2014 at 03:15:47PM -0700, Andrew Morton wrote:
> On Tue,  1 Jul 2014 17:27:34 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > -static struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
> > +static struct alien_cache *__alloc_alien_cache(int node, int entries,
> > +						int batch, gfp_t gfp)
> > +{
> > +	int memsize = sizeof(void *) * entries + sizeof(struct alien_cache);
> 
> nit: all five memsizes in slab.c have type `int'.  size_t would be more
> appropriate.
> 

Hello,

As my inspection, there are 4 memsize. Can you confirm that?
Anyway, here goes the patch you suggested.

Thanks.

----------8<-----------------
