Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85AA26B0038
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 11:50:11 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u78so7970020wmd.13
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:50:11 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d13si2201034edb.88.2017.10.31.08.50.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 08:50:10 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v1 0/1] buddy page accessed before initialized
Date: Tue, 31 Oct 2017 11:50:01 -0400
Message-Id: <20171031155002.21691-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This problem is introduced in linux-next:

a4d28b2d6e64 mm: deferred_init_memmap improvements

If it is more appropriate a create a new patch that includes this fix into
the original patch please let me know.

Pavel Tatashin (1):
  mm: buddy page accessed before initialized

 mm/page_alloc.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
