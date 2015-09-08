Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3D56B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 11:22:33 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so76944252igc.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 08:22:33 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id z6si3472796igz.2.2015.09.08.08.22.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 08:22:33 -0700 (PDT)
Date: Tue, 8 Sep 2015 10:22:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH mm] slab: implement bulking for SLAB allocator
In-Reply-To: <20150908142147.22804.37717.stgit@devil>
Message-ID: <alpine.DEB.2.11.1509081020510.25292@east.gentwo.org>
References: <20150908142147.22804.37717.stgit@devil>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org

On Tue, 8 Sep 2015, Jesper Dangaard Brouer wrote:

> Also notice how well bulking maintains the performance when the bulk
> size increases (which is a soar spot for the slub allocator).

Well you are not actually completing the free action in SLAB. This is
simply queueing the item to be freed later. Also was this test done on a
NUMA system? Alien caches at some point come into the picture.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
