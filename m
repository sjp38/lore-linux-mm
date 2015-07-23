Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 19B1A6B0261
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 10:14:36 -0400 (EDT)
Received: by qgy5 with SMTP id 5so117860726qgy.3
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 07:14:35 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id 30si3683442qkr.1.2015.07.23.07.14.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jul 2015 07:14:35 -0700 (PDT)
Date: Thu, 23 Jul 2015 09:14:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] slub: build detached freelist with look-ahead
In-Reply-To: <20150723130917.6e46e7d0@redhat.com>
Message-ID: <alpine.DEB.2.11.1507230912480.12258@east.gentwo.org>
References: <20150715155934.17525.2835.stgit@devil> <20150715160212.17525.88123.stgit@devil> <20150716115756.311496af@redhat.com> <20150720025415.GA21760@js1304-P5Q-DELUXE> <20150720232817.05f08663@redhat.com> <alpine.DEB.2.11.1507210846060.27213@east.gentwo.org>
 <20150722012819.6b98a599@redhat.com> <20150723063423.GG4449@js1304-P5Q-DELUXE> <20150723130917.6e46e7d0@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>

On Thu, 23 Jul 2015, Jesper Dangaard Brouer wrote:

> > > I was hoping I could define this per slub runtime.  Any chance this
> > > would be made possible?
> >
> > It's not possible to set/reset slab merge in runtime. Once merging
> > happens, one slab could have objects from different kmem_caches so we
> > can't separate it cleanly. Current best approach is to prevent merging
> > when creating new kmem_cache by introducing new slab flag
> > like as SLAB_NO_MERGE.
>
> Yes, the best option would be a new flag (e.g. SLAB_NO_MERGE) when
> creating the kmem_cache.

If this is only in order to stability artificial test loads then the
current kernel parameter is fine afaict. Such a flag has been proposed
numerous times but we never did anything about these requests.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
