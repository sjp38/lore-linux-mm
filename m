Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C4AC06B0266
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 07:54:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b25-v6so718992eds.17
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 04:54:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v25-v6si204360edb.343.2018.08.02.04.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 04:54:27 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w72BsLPD041947
	for <linux-mm@kvack.org>; Thu, 2 Aug 2018 07:54:25 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2km0vc1m7e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Aug 2018 07:54:25 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 2 Aug 2018 12:54:01 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/2] sparc32: switch to NO_BOOTMEM
Date: Thu,  2 Aug 2018 14:53:51 +0300
Message-Id: <1533210833-14748-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>, Michal Hocko <mhocko@kernel.org>, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches convert sparc32 to use memblock + nobootmem.
I've made the conversion as simple as possible, just enough to allow moving
HAVE_MEMBLOCK and NO_BOOTMEM to the common SPARC configuration.

Mike Rapoport (2):
  sparc32: switch to NO_BOOTMEM
  sparc32: tidy up ramdisk memory reservation

 arch/sparc/Kconfig      |  4 +--
 arch/sparc/mm/init_32.c | 90 +++++++++++++++----------------------------------
 2 files changed, 29 insertions(+), 65 deletions(-)

-- 
2.7.4
