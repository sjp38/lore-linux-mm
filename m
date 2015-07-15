Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 864BD28029C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:56:46 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so37843075ieb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 09:56:46 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id g80si4135933ioe.85.2015.07.15.09.56.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jul 2015 09:56:46 -0700 (PDT)
Date: Wed, 15 Jul 2015 11:56:45 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] slub: optimize bulk slowpath free by detached
 freelist
In-Reply-To: <20150715160145.17525.6500.stgit@devil>
Message-ID: <alpine.DEB.2.11.1507151155580.8615@east.gentwo.org>
References: <20150715155934.17525.2835.stgit@devil> <20150715160145.17525.6500.stgit@devil>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>

On Wed, 15 Jul 2015, Jesper Dangaard Brouer wrote:

> Given these properties, the brilliant part is that the detached
> freelist can be constructed without any need for synchronization.
> The freelist is constructed directly in the page objects, without any
> synchronization needed.  The detached freelist is allocated on the
> stack of the function call kmem_cache_free_bulk.  Thus, the freelist
> head pointer is not visible to other CPUs.

Good idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
