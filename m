Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 75D1B6B0269
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 06:52:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z5-v6so4065850edr.19
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 03:52:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 92-v6si812291edg.337.2018.08.06.03.52.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 03:52:48 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w76An47W093149
	for <linux-mm@kvack.org>; Mon, 6 Aug 2018 06:52:46 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kpkkvuam3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 06 Aug 2018 06:52:46 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 6 Aug 2018 11:52:44 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 0/3] sparc32: switch to NO_BOOTMEM
Date: Mon,  6 Aug 2018 13:52:32 +0300
Message-Id: <1533552755-16679-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>, Michal Hocko <mhocko@kernel.org>, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches convert sparc32 to use memblock + nobootmem.
I've made the conversion as simple as possible, just enough to allow moving
HAVE_MEMBLOCK and NO_BOOTMEM to the common SPARC configuration.

v2 changes:
* split whitespace changes to a separate patch
* address Sam's comments [1]

[1] https://lkml.org/lkml/2018/8/2/403

Mike Rapoport (3):
  sparc: mm/init_32: kill trailing whitespace
  sparc32: switch to NO_BOOTMEM
  sparc32: split ramdisk detection and reservation to a helper function

 arch/sparc/Kconfig      |   4 +-
 arch/sparc/mm/init_32.c | 127 ++++++++++++++++++------------------------------
 2 files changed, 50 insertions(+), 81 deletions(-)

-- 
2.7.4
