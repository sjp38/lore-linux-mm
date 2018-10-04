Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA226B0006
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 18:11:13 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id r68-v6so7094179oie.12
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 15:11:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t131-v6si2936016oit.260.2018.10.04.15.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 15:11:11 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w94MB9J8031753
	for <linux-mm@kvack.org>; Thu, 4 Oct 2018 18:11:11 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mwue7808y-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Oct 2018 18:11:10 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Oct 2018 23:11:08 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/2] docs: ReSTify memory-hotplug description 
Date: Fri,  5 Oct 2018 01:10:59 +0300
Message-Id: <1538691061-31289-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

Recently I've noticed that Documentation/memory-hotplug.txt is 
   1) mostly formatted
   2) in a wrong place

These patches split the memory-hotplug.txt to two parts: user/admin
interface and memory hotplug notifier API and place these parts in the
correct places, with some formatting changes.

Mike Rapoport (2):
  docs: move memory hotplug description into admin-guide/mm
  docs/vm: split memory hotplug notifier description to Documentation/core-api

 Documentation/admin-guide/mm/index.rst             |   1 +
 .../mm/memory-hotplug.rst}                         | 152 +++++----------------
 Documentation/core-api/index.rst                   |   2 +
 Documentation/core-api/memory-hotplug-notifier.rst |  84 ++++++++++++
 4 files changed, 122 insertions(+), 117 deletions(-)
 rename Documentation/{memory-hotplug.txt => admin-guide/mm/memory-hotplug.rst} (77%)
 create mode 100644 Documentation/core-api/memory-hotplug-notifier.rst

-- 
2.7.4
