Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id D39FD8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:28:13 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id t46-v6so3253141otf.13
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 02:28:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y207-v6si3455963oia.346.2018.09.14.02.28.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 02:28:12 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8E9O5m6048438
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:28:11 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mg9yy94eg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:28:11 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 10:28:07 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v4 0/3] docs/core-api: add memory allocation guide
Date: Fri, 14 Sep 2018 12:27:55 +0300
Message-Id: <1536917278-31191-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

As Vlastimil mentioned at [1], it would be nice to have some guide about
memory allocation. This set adds such guide that summarizes the "best
practices". 

The changes from the RFC include additions and corrections from Michal and
Randy. I've also added markup to cross-reference the kernel-doc
documentation.

I've split the patch into three to separate labels addition to the exiting
files from the new contents.

v3 -> v4:
  * make GFP_*USER* description less confusing

v2 -> v3:
  * s/HW/hardware

[1] https://www.spinics.net/lists/netfilter-devel/msg55542.html

Mike Rapoport (3):
  docs: core-api/gfp_mask-from-fs-io: add a label for cross-referencing
  docs: core-api/mm-api: add a lable for GFP flags section
  docs: core-api: add memory allocation guide

 Documentation/core-api/gfp_mask-from-fs-io.rst |   2 +
 Documentation/core-api/index.rst               |   1 +
 Documentation/core-api/memory-allocation.rst   | 122 +++++++++++++++++++++++++
 Documentation/core-api/mm-api.rst              |   2 +
 4 files changed, 127 insertions(+)
 create mode 100644 Documentation/core-api/memory-allocation.rst

-- 
2.7.4
