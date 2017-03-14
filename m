Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8B9D6B0038
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 08:52:38 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 68so149978263ioh.4
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 05:52:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v26si14747700pfa.151.2017.03.14.05.52.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 05:52:38 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2ECi76Y051467
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 08:52:36 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 295vx7f6ns-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 08:52:36 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 14 Mar 2017 12:52:34 -0000
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCHv2 0/2] mm: add private lock to serialize memory hotplug operations
Date: Tue, 14 Mar 2017 13:52:24 +0100
Message-Id: <20170314125226.16779-1-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

v1->v2:
Add Acks from Dan and Raphael. Otherwise the patches are identical to v1.

v1:
These two patches are supposed to hopefully fix a memory hotplug
problem reported by Sebastian Ott.

Heiko Carstens (2):
  mm: add private lock to serialize memory hotplug operations
  drivers core: remove assert_held_device_hotplug()

 drivers/base/core.c    | 5 -----
 include/linux/device.h | 1 -
 kernel/memremap.c      | 4 ----
 mm/memory_hotplug.c    | 6 +++++-
 4 files changed, 5 insertions(+), 11 deletions(-)

-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
