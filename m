Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7BD6B0038
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:35:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f5so93595437pgi.1
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 04:35:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l187si2069918pfc.285.2017.01.20.04.35.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 04:35:03 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0KCYMMF077348
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:35:03 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 283j0a1qjr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:35:02 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Fri, 20 Jan 2017 12:35:00 -0000
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 1/3] memblock: let memblock_type_name know about physmem type
Date: Fri, 20 Jan 2017 13:34:54 +0100
In-Reply-To: <20170120123456.46508-1-heiko.carstens@de.ibm.com>
References: <20170120123456.46508-1-heiko.carstens@de.ibm.com>
Message-Id: <20170120123456.46508-2-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since commit 70210ed950b5 ("mm/memblock: add physical memory list")
the memblock structure knows about a physical memory list.

memblock_type_name() should return "physmem" instead of "unknown" if
the name of the physmem memblock_type is being asked for.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 mm/memblock.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index 7608bc305936..acbfa1dffff2 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -72,6 +72,10 @@ memblock_type_name(struct memblock_type *type)
 		return "memory";
 	else if (type == &memblock.reserved)
 		return "reserved";
+#ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
+	else if (type == &memblock.physmem)
+		return "physmem";
+#endif
 	else
 		return "unknown";
 }
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
