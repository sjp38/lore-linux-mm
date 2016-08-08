Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 360606B025F
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 14:27:36 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so77752032wmz.2
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 11:27:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e125si19728741wma.60.2016.08.08.11.27.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 11:27:33 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u78H5ZRK030813
	for <linux-mm@kvack.org>; Mon, 8 Aug 2016 14:27:31 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24nbvwkeeb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 08 Aug 2016 14:27:31 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 8 Aug 2016 12:27:30 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH 0/4] powerpc/mm: movable hotplug memory nodes
Date: Mon,  8 Aug 2016 13:27:19 -0500
Message-Id: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jonathan Corbet <corbet@lwn.net>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

These changes enable onlining memory into ZONE_MOVABLE on power, and the
creation of discrete nodes of movable memory.

Node hotplug is not supported on power [1]. The approach taken instead is to
create a memoryless placeholder node for the designated address range at boot.
Hotplug and onlining of the memory are then done in the usual way.

The numa code on power currently prevents hotplugging to a memoryless node.
This limitation has been questioned before [2], and judging by the response,
there doesn't seem to be a reason we can't remove it. No issues have been
found in light testing.

[1] commit 3af229f ("powerpc/numa: Reset node_possible_map to only node_online_map")
[2] http://lkml.kernel.org/r/CAGZKiBrmkSa1yyhbf5hwGxubcjsE5SmkSMY4tpANERMe2UG4bg@mail.gmail.com
    http://lkml.kernel.org/r/20160511215051.GF22115@arbab-laptop.austin.ibm.com

Reza Arbab (4):
  dt-bindings: add doc for ibm,hotplug-aperture
  powerpc/mm: create numa nodes for hotplug memory
  powerpc/mm: allow memory hotplug into a memoryless node
  mm: enable CONFIG_MOVABLE_NODE on powerpc

 .../bindings/powerpc/opal/hotplug-aperture.txt     | 26 ++++++++++++++++++++++
 Documentation/kernel-parameters.txt                |  2 +-
 arch/powerpc/mm/numa.c                             | 23 ++++++++-----------
 mm/Kconfig                                         |  2 +-
 4 files changed, 37 insertions(+), 16 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
