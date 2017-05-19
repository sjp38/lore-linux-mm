Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08991831F8
	for <linux-mm@kvack.org>; Fri, 19 May 2017 17:01:18 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q125so68021659pgq.8
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:01:18 -0700 (PDT)
Received: from mail-pg0-f54.google.com (mail-pg0-f54.google.com. [74.125.83.54])
        by mx.google.com with ESMTPS id s1si9457442plk.256.2017.05.19.14.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 14:01:17 -0700 (PDT)
Received: by mail-pg0-f54.google.com with SMTP id u187so43144982pgb.0
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:01:17 -0700 (PDT)
From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH 0/3] mm/slub: Fix unused function warnings
Date: Fri, 19 May 2017 14:00:33 -0700
Message-Id: <20170519210036.146880-1-mka@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>

This series fixes a bunch of warnings about unused functions in SLUB

Matthias Kaehlcke (3):
  mm/slub: Only define kmalloc_large_node_hook() for NUMA systems
  mm/slub: Mark slab_free_hook() as __maybe_unused
  mm/slub: Put tid_to_cpu() and tid_to_event() inside #ifdef block

 mm/slub.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

-- 
2.13.0.303.g4ebf302169-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
