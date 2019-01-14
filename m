Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 888508E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:55:15 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d31so24190531qtc.4
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 01:55:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f1si7385472qkc.106.2019.01.14.01.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 01:55:14 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0E9mdEJ074237
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:55:14 -0500
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q0n1fyy94-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:55:14 -0500
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 14 Jan 2019 09:55:13 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V7 5/5] testing
Date: Mon, 14 Jan 2019 15:24:38 +0530
In-Reply-To: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com>
References: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190114095438.32470-7-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

---
 mm/gup.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 6e8152594e83..91849c39931a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1226,7 +1226,7 @@ static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
 		 * be pinning these entries, we might as well move them out
 		 * of the CMA zone if possible.
 		 */
-		if (is_migrate_cma_page(pages[i])) {
+		if (true || is_migrate_cma_page(pages[i])) {
 
 			struct page *head = compound_head(pages[i]);
 
@@ -1256,6 +1256,7 @@ static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
 		for (i = 0; i < nr_pages; i++)
 			put_page(pages[i]);
 
+		pr_emerg("migrating nr_pages");
 		if (migrate_pages(&cma_page_list, new_non_cma_page,
 				  NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE)) {
 			/*
@@ -1274,10 +1275,11 @@ static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
 		nr_pages = get_user_pages(start, nr_pages, gup_flags, pages, vmas);
 		if ((nr_pages > 0) && migrate_allow) {
 			drain_allow = true;
-			goto check_again;
+			//goto check_again;
 		}
 	}
 
+	pr_emerg("Returning with %ld\n", nr_pages);
 	return nr_pages;
 }
 #else
-- 
2.20.1
