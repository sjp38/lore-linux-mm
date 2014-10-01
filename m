Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id DDCAC6B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 16:35:38 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id hi2so1987119wib.2
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 13:35:38 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id q9si22198579wiz.17.2014.10.01.13.35.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 13:35:38 -0700 (PDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so1512374wgg.13
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 13:35:38 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH] mm: ksm use pr_err instead of printk
Date: Wed,  1 Oct 2014 21:35:30 +0100
Message-Id: <1412195730-9629-1-git-send-email-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, neilb@suse.de, sasha.levin@oracle.com, rientjes@google.com, hughd@google.com, joe@perches.com, paul.gortmaker@windriver.com, liwanp@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

WARNING: Prefer: pr_err(...  to printk(KERN_ERR ...

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/ksm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index fb75902..79a26b4 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2310,7 +2310,7 @@ static int __init ksm_init(void)
 
 	ksm_thread = kthread_run(ksm_scan_thread, NULL, "ksmd");
 	if (IS_ERR(ksm_thread)) {
-		printk(KERN_ERR "ksm: creating kthread failed\n");
+		pr_err(KERN_ERR "ksm: creating kthread failed\n");
 		err = PTR_ERR(ksm_thread);
 		goto out_free;
 	}
@@ -2318,7 +2318,7 @@ static int __init ksm_init(void)
 #ifdef CONFIG_SYSFS
 	err = sysfs_create_group(mm_kobj, &ksm_attr_group);
 	if (err) {
-		printk(KERN_ERR "ksm: register sysfs failed\n");
+		pr_err(KERN_ERR "ksm: register sysfs failed\n");
 		kthread_stop(ksm_thread);
 		goto out_free;
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
