Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2353D6B025F
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 21:03:24 -0400 (EDT)
Received: by mail-io0-f170.google.com with SMTP id q128so4325574iof.3
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 18:03:24 -0700 (PDT)
Received: from resqmta-po-02v.sys.comcast.net (resqmta-po-02v.sys.comcast.net. [2001:558:fe16:19:96:114:154:161])
        by mx.google.com with ESMTPS id o36si25669548ioi.7.2016.03.28.18.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 18:03:18 -0700 (PDT)
Date: Mon, 28 Mar 2016 20:03:16 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 06/11] mm/slab: don't keep free slabs if free_objects
 exceeds free_limit
In-Reply-To: <1459142821-20303-7-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1603282000270.31323@east.gentwo.org>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com> <1459142821-20303-7-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 28 Mar 2016, js1304@gmail.com wrote:

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Currently, determination to free a slab is done whenever free object is
> put into the slab. This has a problem that free slabs are not freed
> even if we have free slabs and have more free_objects than free_limit

There needs to be a better explanation here since I do not get why there
is an issue with checking after free if a slab is actually free.

> when processed slab isn't a free slab. This would cause to keep
> too much memory in the slab subsystem. This patch try to fix it
> by checking number of free object after all free work is done. If there
> is free slab at that time, we can free it so we keep free slab as minimal
> as possible.

Ok if we check after free work is done then the number of free slabs may
be higher than the limit set and then we free the additional slabs to get
down to the limit that was set?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
