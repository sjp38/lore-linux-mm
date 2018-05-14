Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2CAD76B000A
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:13:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 3-v6so9094063wry.0
        for <linux-mm@kvack.org>; Mon, 14 May 2018 01:13:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q4-v6si1472668edg.352.2018.05.14.01.13.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 01:13:51 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4E84ILm043307
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:13:50 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hy4sc4yq2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:13:49 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 14 May 2018 09:13:47 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/3] docs/vm: transhuge: split userspace bits to admin-guide/mm 
Date: Mon, 14 May 2018 11:13:37 +0300
Message-Id: <1526285620-453-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

Here are minor updates to transparent hugepage docs. Except from minor
formatting and spelling updates, these patches re-arrange the transhuge.rst
so that userspace interface description will not be interleaved with the
implementation details and it would be possible to split the userspace
related bits to Documentation/admin-guide/mm, which is done by the third
patch.

Mike Rapoport (3):
  docs/vm: transhuge: change sections order
  docs/vm: transhuge: minor updates
  docs/vm: transhuge: split userspace bits to admin-guide/mm/transhuge

 Documentation/admin-guide/kernel-parameters.txt |   3 +-
 Documentation/admin-guide/mm/index.rst          |   1 +
 Documentation/admin-guide/mm/transhuge.rst      | 418 ++++++++++++++++++++++++
 Documentation/vm/transhuge.rst                  | 395 +---------------------
 4 files changed, 426 insertions(+), 391 deletions(-)
 create mode 100644 Documentation/admin-guide/mm/transhuge.rst

-- 
2.7.4
