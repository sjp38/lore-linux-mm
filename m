Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 022A76B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:22:36 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id j124so56840197ith.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:22:35 -0700 (PDT)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [96.114.154.163])
        by mx.google.com with ESMTPS id l5si31256022ioe.59.2016.08.09.09.22.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 09:22:35 -0700 (PDT)
Date: Tue, 9 Aug 2016 11:21:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm/slub: Run free_partial() outside of the
 kmem_cache_node->list_lock
In-Reply-To: <1470759070-18743-1-git-send-email-chris@chris-wilson.co.uk>
Message-ID: <alpine.DEB.2.20.1608091121070.12004@east.gentwo.org>
References: <1470756466-12493-1-git-send-email-chris@chris-wilson.co.uk> <1470759070-18743-1-git-send-email-chris@chris-wilson.co.uk>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Safonov <dsafonov@virtuozzo.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Dave Gordon <david.s.gordon@intel.com>, linux-mm@kvack.org

On Tue, 9 Aug 2016, Chris Wilson wrote:

> With debugobjects enabled and using SLAB_DESTROY_BY_RCU, when a
> kmem_cache_node is destroyed the call_rcu() may trigger a slab
> allocation to fill the debug object pool (__debug_object_init:fill_pool).
> Everywhere but during kmem_cache_destroy(), discard_slab() is performed
> outside of the kmem_cache_node->list_lock and avoids a lockdep warning
> about potential recursion:

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
