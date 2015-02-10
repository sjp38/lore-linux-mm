Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id D1C256B006C
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 14:48:15 -0500 (EST)
Received: by mail-yk0-f179.google.com with SMTP id 9so1672918ykp.10
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 11:48:14 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id e56si3214355yho.173.2015.02.10.11.48.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 10 Feb 2015 11:48:13 -0800 (PST)
Message-Id: <20150210194804.288708936@linux.com>
Date: Tue, 10 Feb 2015 13:48:04 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 0/3] Slab allocator array operations V2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

V1->V2:
- Allocator will determine how to acquire the objects. Remove
  the flags that we exposed to the subsystems in V1.
- Restructure patch a bit to minimize size
- Add material provided by Jesper.

Attached a series of 3 patches to implement functionality to allocate
arrays of pointers to slab objects. This can be used by the slab
allocators to offer more optimized allocation and free paths.

Allocator performance issues were discovered by the network subsystem
developers when trying to get the kernel to send at line rate to
saturate a 40G link. Jesper developed special queueing methods
to compensate for the performance issues. See the following material:

LWN: Improving Linux networking performance
 - http://lwn.net/Articles/629155/
 - YouTube: https://www.youtube.com/watch?v=3XG9-X777Jo

LWN: Toward a more efficient slab allocator
 - http://lwn.net/Articles/629152/
 - YouTube: https://www.youtube.com/watch?v=s0lZzP1jOzI


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
