Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0656B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 13:49:02 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a71so2570257lfb.13
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 10:49:02 -0700 (PDT)
Received: from special.mail1.smtp.beget.ru (special.mail1.smtp.beget.ru. [5.101.158.91])
        by mx.google.com with ESMTPS id f73si1809246lfe.391.2017.03.24.10.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 10:49:01 -0700 (PDT)
Received: from [5.101.159.150] (port=59282 helo=rin)
	by smtp.beget.ru with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.89-beget)
	(envelope-from <apolyakov@beget.ru>)
	id 1crTKe-0005wq-J2
	for linux-mm@kvack.org; Fri, 24 Mar 2017 20:49:00 +0300
Message-ID: <1490377730.30219.2.camel@beget.ru>
Subject: [PATCH] Fix print order in show_free_areas()
From: Alexander Polakov <apolyakov@beget.ru>
Date: Fri, 24 Mar 2017 20:48:50 +0300
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Better seen in context: https://github.com/torvalds/linux/blob/master/m
m/page_alloc.c#L4500

Signed-off-by: Alexander Polyakov <apolyakov@beget.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8afb60c..7b528c7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4398,13 +4398,13 @@ void show_free_areas(unsigned int filter)
A 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
A 			K(node_page_state(pgdat, NR_FILE_DIRTY)),
A 			K(node_page_state(pgdat, NR_WRITEBACK)),
+			K(node_page_state(pgdat, NR_SHMEM)),
A #ifdef CONFIG_TRANSPARENT_HUGEPAGE
A 			K(node_page_state(pgdat, NR_SHMEM_THPS) *
HPAGE_PMD_NR),
A 			K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
A 					* HPAGE_PMD_NR),
A 			K(node_page_state(pgdat, NR_ANON_THPS) *
HPAGE_PMD_NR),
A #endif
-			K(node_page_state(pgdat, NR_SHMEM)),
A 			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
A 			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
A 			node_page_state(pgdat, NR_PAGES_SCANNED),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
