Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C66A16B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 13:30:45 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m124so1187600itg.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:30:45 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id j42si27101301iod.197.2016.05.27.10.30.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 10:30:45 -0700 (PDT)
Date: Fri, 27 May 2016 12:30:43 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v1] [mm] Set page->slab_cache for every page allocated
 for a kmem_cache.
In-Reply-To: <1464369240-35844-1-git-send-email-glider@google.com>
Message-ID: <alpine.DEB.2.20.1605271229330.30511@east.gentwo.org>
References: <1464369240-35844-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 27 May 2016, Alexander Potapenko wrote:

> It's reasonable to rely on the fact that for every page allocated for a
> kmem_cache the |slab_cache| field points to that cache. Without that it's
> hard to figure out which cache does an allocated object belong to.

The flags are set only in the head page of a coumpound page which is used
by SLAB. No need to do this. This would just mean unnecessarily dirtying
struct page cachelines on allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
