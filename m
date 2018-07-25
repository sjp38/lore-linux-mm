Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00CDE6B028A
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n4-v6so2995380edr.5
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 04:26:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o13-v6si1073606edh.418.2018.07.25.04.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 04:26:26 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6PBP7Q0108815
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:25 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kepdcn37f-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:25 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 25 Jul 2018 12:26:23 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 3/7] docs/core-api: kill trailing whitespace in kernel-api.rst
Date: Wed, 25 Jul 2018 14:26:06 +0300
In-Reply-To: <1532517970-16409-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532517970-16409-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532517970-16409-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/core-api/kernel-api.rst | 1 -
 1 file changed, 1 deletion(-)

diff --git a/Documentation/core-api/kernel-api.rst b/Documentation/core-api/kernel-api.rst
index 76fe2d0f..25e9496 100644
--- a/Documentation/core-api/kernel-api.rst
+++ b/Documentation/core-api/kernel-api.rst
@@ -437,4 +437,3 @@ Read-Copy Update (RCU)
 .. kernel-doc:: include/linux/rcu_sync.h
 
 .. kernel-doc:: kernel/rcu/sync.c
-
-- 
2.7.4
