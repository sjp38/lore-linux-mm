Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD0CA6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:40 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j33-v6so9362329qtc.18
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 23:40:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o1-v6si1386373qtj.229.2018.04.23.23.40.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 23:40:39 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3O6ectY072079
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:38 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hhxx89sq4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:37 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Apr 2018 07:40:35 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/7] docs/vm: update KSM documentation
Date: Tue, 24 Apr 2018 09:40:21 +0300
Message-Id: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches extend KSM documentation with high level design overview and
some details about reverse mappings and split the userspace interface
description to Documentation/admin-guide/mm.

The description of some KSM sysfs attributes is changed so that it won't
include implementation detail. The description of these implementation
details are moved to the new "Design" section.

The last patch in the series depends on the patchset that create
Documentation/admin-guide/mm [1], all the rest applies cleanly to the
current docs-next.

[1] https://lkml.org/lkml/2018/4/18/110

Mike Rapoport (7):
  mm/ksm: docs: extend overview comment and make it "DOC:"
  docs/vm: ksm: (mostly) formatting updates
  docs/vm: ksm: add "Design" section
  docs/vm: ksm: reshuffle text between "sysfs" and "design" sections
  docs/vm: ksm: update stable_node_chains_prune_millisecs description
  docs/vm: ksm: udpate description of stable_node_{dups,chains}
  docs/vm: ksm: split userspace interface to admin-guide/mm/ksm.rst

 Documentation/admin-guide/mm/index.rst |   1 +
 Documentation/admin-guide/mm/ksm.rst   | 189 ++++++++++++++++++++++++++
 Documentation/vm/ksm.rst               | 234 ++++++++++-----------------------
 mm/ksm.c                               |  19 ++-
 4 files changed, 277 insertions(+), 166 deletions(-)
 create mode 100644 Documentation/admin-guide/mm/ksm.rst

-- 
2.7.4
