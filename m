Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2A39F6B005D
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 13:27:32 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 09/10] ksm: change copyright message
Date: Fri, 17 Jul 2009 20:30:49 +0300
Message-Id: <1247851850-4298-10-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-9-git-send-email-ieidus@redhat.com>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
 <1247851850-4298-4-git-send-email-ieidus@redhat.com>
 <1247851850-4298-5-git-send-email-ieidus@redhat.com>
 <1247851850-4298-6-git-send-email-ieidus@redhat.com>
 <1247851850-4298-7-git-send-email-ieidus@redhat.com>
 <1247851850-4298-8-git-send-email-ieidus@redhat.com>
 <1247851850-4298-9-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ieidus@redhat.com
List-ID: <linux-mm.kvack.org>

From: Izik Eidus <ieidus@redhat.com>

Adding Hugh Dickins into the authors list.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/ksm.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index a0fbdb2..75d7802 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -4,11 +4,12 @@
  * This code enables dynamic sharing of identical pages found in different
  * memory areas, even if they are not shared by fork()
  *
- * Copyright (C) 2008 Red Hat, Inc.
+ * Copyright (C) 2008-2009 Red Hat, Inc.
  * Authors:
  *	Izik Eidus
  *	Andrea Arcangeli
  *	Chris Wright
+ *	Hugh Dickins
  *
  * This work is licensed under the terms of the GNU GPL, version 2.
  */
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
