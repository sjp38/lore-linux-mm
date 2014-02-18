Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 84EBE6B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:08:33 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id f15so8145661eak.16
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:08:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v48si43040188eeo.146.2014.02.18.14.08.29
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 14:08:30 -0800 (PST)
Date: Tue, 18 Feb 2014 17:00:27 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH] fs/proc/meminfo: meminfo_proc_show(): fix typo in comment
Message-ID: <20140218170027.00bcf592@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, riel@redhat.com, akpm@linux-foundation.org, james.leddy@redhat.com

It should read "reclaimable slab" and not "reclaimable swap".

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
---
 fs/proc/meminfo.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 136e548..7445af0 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -73,7 +73,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	available += pagecache;
 
 	/*
-	 * Part of the reclaimable swap consists of items that are in use,
+	 * Part of the reclaimable slab consists of items that are in use,
 	 * and cannot be freed. Cap this estimate at the low watermark.
 	 */
 	available += global_page_state(NR_SLAB_RECLAIMABLE) -
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
