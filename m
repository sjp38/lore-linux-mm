Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 76BA76B0069
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 17:02:49 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id ro13so99748273pac.7
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 14:02:49 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w126si23811342pgb.85.2016.11.14.14.02.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 14:02:48 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAELwV57144046
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 17:02:47 -0500
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26qnd9gqes-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 17:02:47 -0500
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 14 Nov 2016 15:02:46 -0700
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH v7 5/5] dt: add documentation of "hotpluggable" memory property
Date: Mon, 14 Nov 2016 16:02:41 -0600
In-Reply-To: <1479160961-25840-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1479160961-25840-1-git-send-email-arbab@linux.vnet.ibm.com>
Message-Id: <1479160961-25840-6-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, devicetree@vger.kernel.org, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

Summarize the "hotpluggable" property of dt memory nodes.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 Documentation/devicetree/booting-without-of.txt | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/Documentation/devicetree/booting-without-of.txt b/Documentation/devicetree/booting-without-of.txt
index 3f1437f..280d283 100644
--- a/Documentation/devicetree/booting-without-of.txt
+++ b/Documentation/devicetree/booting-without-of.txt
@@ -974,6 +974,13 @@ compatibility.
       4Gb. Some vendors prefer splitting those ranges into smaller
       segments, but the kernel doesn't care.
 
+  Additional properties:
+
+    - hotpluggable : The presence of this property provides an explicit
+      hint to the operating system that this memory may potentially be
+      removed later. The kernel can take this into consideration when
+      doing nonmovable allocations and when laying out memory zones.
+
   e) The /chosen node
 
   This node is a bit "special". Normally, that's where Open Firmware
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
