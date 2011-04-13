Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 607BC900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 22:16:32 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p3D2GSZJ020012
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:16:29 -0700
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by wpaz21.hot.corp.google.com with ESMTP id p3D2G9ou028896
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:16:27 -0700
Received: by pvg12 with SMTP id 12so64896pvg.19
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:16:23 -0700 (PDT)
Date: Tue, 12 Apr 2011 19:16:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: Fix a typo in config name
In-Reply-To: <alpine.DEB.2.00.1104121301430.14692@router.home>
Message-ID: <alpine.DEB.2.00.1104121913410.15979@chino.kir.corp.google.com>
References: <4DA3FDB2.9090100@cn.fujitsu.com> <alpine.DEB.2.00.1104121301430.14692@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 12 Apr 2011, Christoph Lameter wrote:

> On Tue, 12 Apr 2011, Li Zefan wrote:
> 
> > There's no config named SLAB_DEBUG, and it should be a typo
> > of SLUB_DEBUG.
> >
> > Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> > ---
> >
> > not slub expert, don't know how this bug affects slub debugging.
> 
> Affects the bootstrap code.
> 

I don't see how, there should be no partial or full slabs for either 
kmem_cache or kmem_cache_node at this point in the boot sequence.  I think 
kmem_cache_bootstrap_fixup() should only need to add the cache to the list 
of slab caches and set the refcount accordingly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
