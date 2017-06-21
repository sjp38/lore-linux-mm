Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE42C6B0433
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 14:20:00 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 64so26331458wrp.4
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 11:20:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z85si13212912wmh.60.2017.06.21.11.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 11:19:59 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5LIIXYV018450
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 14:19:58 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b7r1munpw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 14:19:57 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zohar@linux.vnet.ibm.com>;
	Thu, 22 Jun 2017 04:19:55 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v5LIJjt0983350
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 04:19:53 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v5LIJLmB028188
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 04:19:21 +1000
From: Mimi Zohar <zohar@linux.vnet.ibm.com>
Subject: [PATCH v2 05/10] tmpfs: define integrity_read method
Date: Wed, 21 Jun 2017 14:18:25 -0400
In-Reply-To: <1498069110-10009-1-git-send-email-zohar@linux.vnet.ibm.com>
References: <1498069110-10009-1-git-send-email-zohar@linux.vnet.ibm.com>
Message-Id: <1498069110-10009-6-git-send-email-zohar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>, James Morris <jmorris@namei.org>, linux-fsdevel@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Define an ->integrity_read file operation method to read data for
integrity hash collection.

Signed-off-by: Mimi Zohar <zohar@linux.vnet.ibm.com>
---
 mm/shmem.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index e67d6ba4e98e..16958b20946f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3846,6 +3846,7 @@ static const struct file_operations shmem_file_operations = {
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= iter_file_splice_write,
 	.fallocate	= shmem_fallocate,
+	.integrity_read	= shmem_file_read_iter,
 #endif
 };
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
