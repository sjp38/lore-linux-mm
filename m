Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E020280251
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:43:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d128so24197362wmf.2
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:43:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e133si10125256wma.73.2016.10.23.21.43.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:43:00 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4cX4W035186
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:59 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 268qn3xc1c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:58 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 14:42:54 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 923B62CE8054
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:51 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4gp8S17039464
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:51 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4gp9V030753
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:51 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 08/10] powerpc: Enable CONFIG_MOVABLE_NODE for PPC64 platform
Date: Mon, 24 Oct 2016 10:12:27 +0530
In-Reply-To: <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477284149-2976-9-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

Just enable MOVABLE_NODE config option for PPC64 platform by default.
This prevents accidentally building the kernel without the required
config option.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 65fba4c..3989d89 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -310,6 +310,10 @@ config PGTABLE_LEVELS
 	default 3 if PPC_64K_PAGES && !PPC_BOOK3S_64
 	default 4
 
+config MOVABLE_NODE
+	bool
+	default y if PPC64
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
