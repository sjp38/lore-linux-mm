Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 476E86B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 18:57:58 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id h15so4586993igd.5
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:57:58 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id d4si5825128igc.38.2014.07.22.15.57.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 15:57:57 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so309141iec.12
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:57:57 -0700 (PDT)
Date: Tue, 22 Jul 2014 15:57:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 0/2] mm, slub: remaining changes for -mm
Message-ID: <alpine.DEB.2.02.1407221550500.9885@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Dan Carpenter <dan.carpenter@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Two patches remain in Pekka's slab/next branch that can deferred to 3.17 
but need to get pushed to -mm.

Unless there's an objection, it should be possible to remove Pekka's slab 
trees from linux-next until he starts pushing changes again.
---
 mm/slub.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
