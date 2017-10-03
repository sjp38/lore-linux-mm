Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 097DC6B0253
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 01:53:18 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y8so241008wrd.0
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 22:53:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c60si2462554edd.420.2017.10.02.22.53.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 22:53:16 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v935nFZO084945
	for <linux-mm@kvack.org>; Tue, 3 Oct 2017 01:53:15 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dbyjfpgs8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 03 Oct 2017 01:53:15 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 3 Oct 2017 06:53:13 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] include/linux/fs.h: fix comment about struct address_space
Date: Tue,  3 Oct 2017 08:53:07 +0300
Message-Id: <1507009987-8746-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Before commit 9c5d760b8d22 ("mm: split gfp_mask and mapping flags into
separate fields") the private_* fields of struct adrress_space were grouped
together and using "ditto" in comments describing the last fields was
correct.

With introduction of gpf_mask between private_lock and private_list "ditto"
references the wrong description.

Fix it by using the elaborate description.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/fs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 339e73742e73..13dab191a23e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -403,7 +403,7 @@ struct address_space {
 	unsigned long		flags;		/* error bits */
 	spinlock_t		private_lock;	/* for use by the address_space */
 	gfp_t			gfp_mask;	/* implicit gfp mask for allocations */
-	struct list_head	private_list;	/* ditto */
+	struct list_head	private_list;	/* for use by the address_space */
 	void			*private_data;	/* ditto */
 	errseq_t		wb_err;
 } __attribute__((aligned(sizeof(long)))) __randomize_layout;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
