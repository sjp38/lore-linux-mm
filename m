Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F18536B0008
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:22:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id v26-v6so745519eds.9
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 05:22:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q1-v6si1439996edb.153.2018.07.26.05.22.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 05:22:14 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6QCIifm068098
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:22:12 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kfe31ge0v-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:22:11 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Jul 2018 13:22:09 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 0/7] memory management documentation updates
Date: Thu, 26 Jul 2018 15:21:55 +0300
Message-Id: <1532607722-17079-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

Here are several updates to the mm documentation.

Aside from really minor changes in the first three patches, the updates
are:

* move the documentation of kstrdup and friends to "String Manipulation"
  section
* split memory management API into a separate .rst file
* adjust formating of the GFP flags description and include it in the
  reference documentation.

v2 changes:
* move get_user_pages_fast documentation to "User Space Memory Access" as
  suggested by Matthew
* more elaborate changelog for the fifth patch

Mike Rapoport (7):
  mm/util: make strndup_user description a kernel-doc comment
  mm/util: add kernel-doc for kvfree
  docs/core-api: kill trailing whitespace in kernel-api.rst
  docs/core-api: move *{str,mem}dup* to "String Manipulation"
  docs/core-api: split memory management API to a separate file
  docs/mm: make GFP flags descriptions usable as kernel-doc
  docs/core-api: mm-api: add section about GFP flags

 Documentation/core-api/index.rst      |   1 +
 Documentation/core-api/kernel-api.rst |  59 +------
 Documentation/core-api/mm-api.rst     |  79 +++++++++
 include/linux/gfp.h                   | 291 ++++++++++++++++++----------------
 mm/util.c                             |   9 +-
 5 files changed, 246 insertions(+), 193 deletions(-)
 create mode 100644 Documentation/core-api/mm-api.rst

-- 
2.7.4
