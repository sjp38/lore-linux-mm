Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F07536B08B8
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 10:47:29 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i26-v6so3287671edr.4
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 07:47:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 89-v6si2820300edr.430.2018.08.17.07.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 07:47:28 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7HEiBK6097746
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 10:47:27 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kwxamdhw5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 10:47:26 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 17 Aug 2018 15:47:25 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v3 0/3] docs/core-api: add memory allocation guide
Date: Fri, 17 Aug 2018 17:47:13 +0300
Message-Id: <1534517236-16762-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Michal Hocko <mhocko@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

As Vlastimil mentioned at [1], it would be nice to have some guide about
memory allocation. This set adds such guide that summarizes the "best
practices". 

The changes from the RFC include additions and corrections from Michal and
Randy. I've also added markup to cross-reference the kernel-doc
documentation.

I've split the patch into three to separate labels addition to the exiting
files from the new contents.

Note that the second patch depends on the mm docs update [2] that Andrew
took to the -mm tree.

v2 -> v3:
  * s/HW/hardware

[1] https://www.spinics.net/lists/netfilter-devel/msg55542.html
[2] https://lkml.org/lkml/2018/7/26/684

Mike Rapoport (3):
  docs: core-api/gfp_mask-from-fs-io: add a label for cross-referencing
  docs: core-api/mm-api: add a lable for GFP flags section
  docs: core-api: add memory allocation guide

 Documentation/core-api/gfp_mask-from-fs-io.rst |   2 +
 Documentation/core-api/index.rst               |   1 +
 Documentation/core-api/memory-allocation.rst   | 124 +++++++++++++++++++++++++
 Documentation/core-api/mm-api.rst              |   2 +
 4 files changed, 129 insertions(+)
 create mode 100644 Documentation/core-api/memory-allocation.rst

-- 
2.7.4
