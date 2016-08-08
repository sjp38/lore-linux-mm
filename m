Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id F23006B025F
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 14:27:33 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id pp5so608688308pac.3
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 11:27:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x6si38147873pac.8.2016.08.08.11.27.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 11:27:32 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u78He87n137687
	for <linux-mm@kvack.org>; Mon, 8 Aug 2016 14:27:32 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24nc22kjsc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 08 Aug 2016 14:27:32 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 8 Aug 2016 12:27:31 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH 1/4] dt-bindings: add doc for ibm,hotplug-aperture
Date: Mon,  8 Aug 2016 13:27:20 -0500
In-Reply-To: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com>
Message-Id: <1470680843-28702-2-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jonathan Corbet <corbet@lwn.net>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 .../bindings/powerpc/opal/hotplug-aperture.txt     | 26 ++++++++++++++++++++++
 1 file changed, 26 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt

diff --git a/Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt b/Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt
new file mode 100644
index 0000000..b8dffaa
--- /dev/null
+++ b/Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt
@@ -0,0 +1,26 @@
+Designated hotplug memory
+-------------------------
+
+This binding describes a region of hotplug memory which is not present at boot,
+allowing its eventual NUMA associativity to be prespecified.
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
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
