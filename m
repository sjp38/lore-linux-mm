Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BFE686B0038
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u84so115307123pfj.6
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:42:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id th2si5484617pab.211.2016.10.23.21.42.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:42:40 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4cWvJ130694
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:39 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 268yyune8x-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:39 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 14:42:36 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C3F482CE8056
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:34 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4gYnC18743532
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:34 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4gYtg030302
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:34 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 01/10] dt-bindings: Add doc for ibm,hotplug-aperture
Date: Mon, 24 Oct 2016 10:12:20 +0530
In-Reply-To: <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477284149-2976-2-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

From: Reza Arbab <arbab@linux.vnet.ibm.com>

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 .../bindings/powerpc/opal/hotplug-aperture.txt     | 26 ++++++++++++++++++++++
 1 file changed, 26 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt

diff --git a/Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt b/Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt
new file mode 100644
index 0000000..04dde03
--- /dev/null
+++ b/Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt
@@ -0,0 +1,26 @@
+Designated hotplug memory
+-------------------------
+
+This binding describes a region of hotplug memory which is not present
+at boot, allowing its eventual NUMA associativity to be prespecified.
+
+Required properties:
+
+- compatible
+	"ibm,hotplug-aperture"
+
+- reg
+	base address and size of the region (standard definition)
+
+- ibm,associativity
+	NUMA associativity (standard definition)
+
+Example:
+
+A 2 GiB aperture at 0x100000000, to be part of nid 3 when hotplugged:
+
+	hotplug-memory@100000000 {
+		compatible = "ibm,hotplug-aperture";
+		reg = <0x0 0x100000000 0x0 0x80000000>;
+		ibm,associativity = <0x4 0x0 0x0 0x0 0x3>;
+	};
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
