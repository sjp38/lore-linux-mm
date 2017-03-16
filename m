Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF8BD6B0396
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 21:43:31 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 14so35763751itw.3
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 18:43:31 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0010.hostedemail.com. [216.40.44.10])
        by mx.google.com with ESMTPS id d22si1979273itb.121.2017.03.15.18.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 18:43:31 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/3] mm: page_alloc: Object code reductions and logging fix
Date: Wed, 15 Mar 2017 18:43:12 -0700
Message-Id: <cover.1489628459.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Joe Perches (3):
  mm: page_alloc: Reduce object size by neatening printks
  mm: page_alloc: Fix misordered logging output, reduce code size
  mm: page_alloc: Break up a long single-line printk

 mm/page_alloc.c | 248 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 127 insertions(+), 121 deletions(-)

-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
