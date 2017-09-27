Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7BF6B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:45:11 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id f51so36996wrf.3
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 10:45:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d52si2099958ede.45.2017.09.27.10.45.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 10:45:09 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8RHi266062287
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:45:08 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2d8dmm2p3h-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:45:07 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 27 Sep 2017 18:45:06 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH 0/3] lsmem/chmem: add memory zone awareness
Date: Wed, 27 Sep 2017 19:44:43 +0200
Message-Id: <20170927174446.20459-1-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: util-linux@vger.kernel.org, Karel Zak <kzak@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andre Wild <wild@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

These patches are against lsmem/chmem in util-linux, they add support
for listing and changing memory zone allocation.

Added Michal Hocko and linux-mm on cc, to raise general awareness for
the lsmem/chmem tools, and the new memory zone functionality in
particular. I think this can be quite useful for memory hotplug kernel
development, and if not, sorry for the noise.

Andre Wild (1):
  lsmem/chmem: add memory zone awareness to bash-completion

Gerald Schaefer (2):
  lsmem/chmem: add memory zone awareness
  tests/lsmem: update lsmem test with ZONES column

 bash-completion/chmem                  |   1 +
 bash-completion/lsmem                  |   2 +-
 sys-utils/chmem.8                      |  19 +++++
 sys-utils/chmem.c                      | 136 +++++++++++++++++++++++++++++++--
 sys-utils/lsmem.1                      |   4 +-
 sys-utils/lsmem.c                      |  98 +++++++++++++++++++++++-
 tests/expected/lsmem/lsmem-s390-zvm-6g |  21 +++++
 tests/expected/lsmem/lsmem-x86_64-16g  |  39 ++++++++++
 tests/ts/lsmem/lsmem                   |   1 +
 9 files changed, 309 insertions(+), 12 deletions(-)

-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
