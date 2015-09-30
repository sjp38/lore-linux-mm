Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9456B0277
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 12:03:09 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so105754716igc.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 09:03:08 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id p19si21286872igs.100.2015.09.30.09.03.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 30 Sep 2015 09:03:08 -0700 (PDT)
Date: Wed, 30 Sep 2015 11:03:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
In-Reply-To: <20150930114255.13505.2618.stgit@canyon>
Message-ID: <alpine.DEB.2.20.1509301102230.1143@east.gentwo.org>
References: <560ABE86.9050508@gmail.com> <20150930114255.13505.2618.stgit@canyon>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

On Wed, 30 Sep 2015, Jesper Dangaard Brouer wrote:

> Make it possible to free a freelist with several objects by adjusting
> API of slab_free() and __slab_free() to have head, tail and an objects
> counter (cnt).

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
