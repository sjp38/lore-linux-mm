Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 35CA26B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:42:02 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b9-v6so21378248wrj.15
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 23:42:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s15si2590273edb.444.2018.04.23.23.42.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 23:42:01 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3O6dEQe125298
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:41:59 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hhybrrhgd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:41:59 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Apr 2018 07:41:57 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/2] mm/ksm: minor cleanups
Date: Tue, 24 Apr 2018 09:41:44 +0300
Message-Id: <1524552106-7356-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

While working on KSM docs, I've noticed some minor points which are
addressed by the below patches.

Mike Rapoport (2):
  mm/ksm: remove unused page_referenced_ksm declaration
  mm/ksm: move [set_]page_stable_node from ksm.h to ksm.c

 include/linux/ksm.h | 17 -----------------
 mm/ksm.c            | 12 ++++++++++++
 2 files changed, 12 insertions(+), 17 deletions(-)

-- 
2.7.4
