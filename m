Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 107F16B0023
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 14:47:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id q6so2856139wre.20
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 11:47:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f10sor7336265edm.50.2018.04.07.11.47.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Apr 2018 11:47:57 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH 3/3] mm: replace S_IRUSR | S_IWUSR with 0600
Date: Sat,  7 Apr 2018 19:47:26 +0100
Message-Id: <20180407184726.8634-3-paulmcquad@gmail.com>
In-Reply-To: <20180407184726.8634-1-paulmcquad@gmail.com>
References: <20180407184726.8634-1-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: konrad.wilk@oracle.com, labbott@redhat.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, guptap@codeaurora.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, rientjes@google.com, mhocko@suse.com, rppt@linux.vnet.ibm.com, dave@stgolabs.net, hmclauchlan@fb.com, tglx@linutronix.de, pombredanne@nexb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Fix checkpatch warnings about S_IRUSR | S_IWUSR being less readable than
providing the permissions octal as '0600'.

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/failslab.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/failslab.c b/mm/failslab.c
index 1f2f248e3601..b135ebb88b6f 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -42,7 +42,7 @@ __setup("failslab=", setup_failslab);
 static int __init failslab_debugfs_init(void)
 {
 	struct dentry *dir;
-	umode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
+	umode_t mode = S_IFREG | 0600;
 
 	dir = fault_create_debugfs_attr("failslab", NULL, &failslab.attr);
 	if (IS_ERR(dir))
-- 
2.16.2
