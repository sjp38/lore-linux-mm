Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83D2A6B000D
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:32:53 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12-v6so1080885edi.12
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:32:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o31-v6si416627edc.358.2018.07.26.10.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 10:32:52 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6QHTddx130100
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:32:50 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kfjrb83af-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:32:50 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Jul 2018 18:32:48 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v3 0/7] memory management documentation updates
Date: Thu, 26 Jul 2018 20:32:33 +0300
Message-Id: <1532626360-16650-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

Here are several updates to the mm documentation.

Aside from really minor changes in the first three patches, the updates
are:

* move the documentation of kstrdup and friends to "String Manipulation"
  section
* split memory management API into a separate .rst file
* adjust formating of the GFP flags description and include it in the
  reference documentation.

v3 changes:
* Use Matthew's wording of intro paragraph in the GFP flags section
* Change "Common Combinations" to "Useful GFP flag combinations"

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
 Documentation/core-api/mm-api.rst     |  78 +++++++++
 include/linux/gfp.h                   | 291 ++++++++++++++++++----------------
 mm/util.c                             |   9 +-
 5 files changed, 245 insertions(+), 193 deletions(-)
 create mode 100644 Documentation/core-api/mm-api.rst

-- 
2.7.4
