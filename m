Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0266B026F
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:26 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so9963615wma.2
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 06:20:26 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n128si2762519wmf.141.2016.11.22.06.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 06:20:25 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAMEIs1s093685
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:23 -0500
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26vpk66b97-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:23 -0500
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 23 Nov 2016 00:20:21 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 4D6742CE8046
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:17 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAMEKH9f26345506
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:17 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAMEKGU1016573
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:17 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 09/12] powerpc: Enable CONFIG_MOVABLE_NODE for PPC64 platform
Date: Tue, 22 Nov 2016 19:49:45 +0530
In-Reply-To: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1479824388-30446-10-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com

Just enable MOVABLE_NODE config option for PPC64 platform by default.
This prevents accidentally building the kernel without the required
config option.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 81bf679..c2ed822 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -311,6 +311,10 @@ config PGTABLE_LEVELS
 	default 3 if PPC_64K_PAGES && !PPC_BOOK3S_64
 	default 4
 
+config MOVABLE_NODE
+	bool
+	default y if PPC64
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
