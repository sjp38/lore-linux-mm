Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB3F6B016A
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 15:15:22 -0400 (EDT)
Received: by mail-qc0-f179.google.com with SMTP id r5so340301qcx.10
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 12:15:22 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id v7si32658426qay.21.2014.06.11.12.15.21
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 12:15:21 -0700 (PDT)
Message-Id: <20140611191510.082006044@linux.com>
Date: Wed, 11 Jun 2014 14:15:10 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 0/3] slab: common kmem_cache_cpu functions V2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

V1->V2
- Add some comments
- Use the new functions in more places to simplify code

The patchset provides two new functions in mm/slab.h and modifies SLAB and
SLUB to use these. The kmem_cache_node structure is shared between both
allocators and the use of common accessors will allow us to move more code
into slab_common.c in the future.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
