Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0196B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 16:07:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g141so22707307wmd.0
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 13:07:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b68si543639wmd.56.2016.09.14.13.07.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 13:07:08 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8EK2poQ053109
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 16:07:06 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25exc0dd6k-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 16:07:06 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 14 Sep 2016 14:07:05 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH v2 0/3] powerpc/mm: movable hotplug memory nodes
Date: Wed, 14 Sep 2016 15:06:55 -0500
Message-Id: <1473883618-14998-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

These changes enable onlining memory into ZONE_MOVABLE on power, and the 
creation of discrete nodes of movable memory.

We provide a way to describe the extents and numa associativity of such 
a node in the device tree, yet still defer the memory addition to take 
place post-boot through hotplug.

In v1, this patchset introduced a new dt compatible id to explicitly 
create a memoryless node at boot. Here, things have been simplified to 
be applicable regardless of the status of node hotplug on power. We 
still intend to enable hotadding a pgdat, but that's now untangled as a 
separate topic.

v2:
* Use the "status" property of standard dt memory nodes instead of 
  introducing a new "ibm,hotplug-aperture" compatible id.

* Remove the patch which explicitly creates a memoryless node. This set 
  no longer has any bearing on whether the pgdat is created at boot or 
  at the time of memory addition.

v1:
* http://lkml.kernel.org/r/1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com

Reza Arbab (3):
  drivers/of: recognize status property of dt memory nodes
  powerpc/mm: allow memory hotplug into a memoryless node
  mm: enable CONFIG_MOVABLE_NODE on powerpc

 Documentation/kernel-parameters.txt |  2 +-
 arch/powerpc/mm/numa.c              | 13 +------------
 drivers/of/fdt.c                    |  8 ++++++++
 mm/Kconfig                          |  2 +-
 4 files changed, 11 insertions(+), 14 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
