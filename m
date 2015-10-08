Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF316B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 12:54:06 -0400 (EDT)
Received: by qkap81 with SMTP id p81so21744236qka.2
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 09:54:06 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id l77si22441869qkh.74.2015.10.08.09.54.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 08 Oct 2015 09:54:05 -0700 (PDT)
Date: Thu, 8 Oct 2015 11:54:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] slab_common: rename cache create/destroy helpers
In-Reply-To: <6a18aab2f1c3088377d7fd2207b4cc1a1a743468.1444319304.git.vdavydov@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1510081153480.23849@east.gentwo.org>
References: <6a18aab2f1c3088377d7fd2207b4cc1a1a743468.1444319304.git.vdavydov@virtuozzo.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 8 Oct 2015, Vladimir Davydov wrote:

> do_kmem_cache_create, do_kmem_cache_shutdown, and do_kmem_cache_release
> sound awkward for static helper functions that are not supposed to be
> used outside slab_common.c. Rename them to create_cache, shutdown_cache,
> and release_caches, respectively. This patch is a pure cleanup and does
> not introduce any functional changes.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
