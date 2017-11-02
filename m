Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 216D56B0253
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 13:02:37 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n33so410432ioi.7
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 10:02:37 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id m65si3493299iod.307.2017.11.02.10.02.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 10:02:29 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v2 0/1] mm: buddy page accessed before initialized
Date: Thu,  2 Nov 2017 13:02:20 -0400
Message-Id: <20171102170221.7401-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

As discussed with Michal Hocko, I am sending a new version of the patch,
where loops are split into two parts: initializing, and freeing.

I also included compiler warning fixes from:
	mm-deferred_init_memmap-improvements-fix.patch

So, this patch should replace two patches in mmots:

mm-deferred_init_memmap-improvements-fix.patch
and
mm-deferred_init_memmap-improvements-fix-2.patch

Again, I can send a new full version of
mm-deferred_init_memmap-improvements.patch

If that is better.

Pavel Tatashin (1):
  mm: buddy page accessed before initialized

 mm/page_alloc.c | 66 +++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 43 insertions(+), 23 deletions(-)

-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
