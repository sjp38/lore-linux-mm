Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 33E236B006C
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 14:20:31 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id s11so18028108qcv.5
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 11:20:31 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id o20si7064390qge.107.2015.01.28.11.20.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 11:20:30 -0800 (PST)
Date: Wed, 28 Jan 2015 13:20:28 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
In-Reply-To: <20150128173221.GA16011@esperanza>
Message-ID: <alpine.DEB.2.11.1501281319570.32767@gentwo.org>
References: <cover.1422461573.git.vdavydov@parallels.com> <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com> <alpine.DEB.2.11.1501281034290.32147@gentwo.org> <20150128173221.GA16011@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 28 Jan 2015, Vladimir Davydov wrote:

> On Wed, Jan 28, 2015 at 10:37:09AM -0600, Christoph Lameter wrote:
> > On Wed, 28 Jan 2015, Vladimir Davydov wrote:
> >
> > > +			/* We do not keep full slabs on the list */
> > > +			BUG_ON(free <= 0);
> >
> > Well sorry we do actually keep a number of empty slabs on the partial
> > lists. See the min_partial field in struct kmem_cache.
>
> It's not about empty slabs, it's about full slabs: free == 0 means slab
> is full.

Correct. I already acked the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
