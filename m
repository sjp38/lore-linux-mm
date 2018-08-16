Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0202A6B000A
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 09:03:56 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 20-v6so4063609ois.21
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 06:03:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v128-v6si16676813oig.380.2018.08.16.06.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 06:03:55 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7GD0uGM122221
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 09:03:53 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kw6p4fqn1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 09:03:52 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 16 Aug 2018 14:03:48 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 1/3] docs: core-api/gfp_mask-from-fs-io: add a label for cross-referencing
Date: Thu, 16 Aug 2018 16:03:36 +0300
In-Reply-To: <1534424618-24713-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1534424618-24713-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1534424618-24713-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Michal Hocko <mhocko@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/core-api/gfp_mask-from-fs-io.rst | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/core-api/gfp_mask-from-fs-io.rst b/Documentation/core-api/gfp_mask-from-fs-io.rst
index e0df8f4..e7c32a8 100644
--- a/Documentation/core-api/gfp_mask-from-fs-io.rst
+++ b/Documentation/core-api/gfp_mask-from-fs-io.rst
@@ -1,3 +1,5 @@
+.. _gfp_mask_from_fs_io:
+
 =================================
 GFP masks used from FS/IO context
 =================================
-- 
2.7.4
