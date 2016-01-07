Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 88125828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 10:54:27 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id q21so256180675iod.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 07:54:27 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id m9si22094517ige.60.2016.01.07.07.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 07:54:27 -0800 (PST)
Date: Thu, 7 Jan 2016 09:54:24 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 01/10] slub: cleanup code for kmem cgroup support to
 kmem_cache_free_bulk
In-Reply-To: <20160107140338.28907.48580.stgit@firesoul>
Message-ID: <alpine.DEB.2.20.1601070953460.28564@east.gentwo.org>
References: <20160107140253.28907.5469.stgit@firesoul> <20160107140338.28907.48580.stgit@firesoul>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, 7 Jan 2016, Jesper Dangaard Brouer wrote:

> +	/* Support for memcg, compiler can optimize this out */
> +	*s = cache_from_obj(*s, object);
> +

Well the indirection on *s presumably cannot be optimized out. And the
indirection is not needed when cgroups are not active.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
