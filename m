Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D1FC06B0012
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 18:00:50 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h132so170661ioe.2
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 15:00:50 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id k16-v6si328727ita.82.2018.03.28.15.00.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 15:00:48 -0700 (PDT)
Date: Wed, 28 Mar 2018 17:00:46 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab, slub: skip unnecessary kasan_cache_shutdown()
In-Reply-To: <20180327230603.54721-1-shakeelb@google.com>
Message-ID: <alpine.DEB.2.20.1803281700230.23247@nuc-kabylake>
References: <20180327230603.54721-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Potapenko <glider@google.com>, Greg Thelen <gthelen@google.com>, Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 27 Mar 2018, Shakeel Butt wrote:

> The kasan quarantine is designed to delay freeing slab objects to catch
> use-after-free. The quarantine can be large (several percent of machine
> memory size). When kmem_caches are deleted related objects are flushed
> from the quarantine but this requires scanning the entire quarantine
> which can be very slow. We have seen the kernel busily working on this
> while holding slab_mutex and badly affecting cache_reaper, slabinfo
> readers and memcg kmem cache creations.

Acked-by: Christoph Lameter <cl@linux.com>
