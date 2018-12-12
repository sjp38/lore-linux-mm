Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91BE38E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 12:27:21 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id y88so15877257pfi.9
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 09:27:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j70si14567077pgd.138.2018.12.12.09.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 09:27:20 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBCHJZLj136171
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 12:27:19 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pb4kxx2m5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 12:27:19 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zaslonko@linux.ibm.com>;
	Wed, 12 Dec 2018 17:27:16 -0000
From: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Subject: [PATCH v2 0/1] Initialize struct pages for the full section
Date: Wed, 12 Dec 2018 18:27:11 +0100
Message-Id: <20181212172712.34019-1-zaslonko@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com, zaslonko@linux.ibm.com

This patch refers to the older thread:
https://marc.info/?t=153658306400001&r=1&w=2

As suggested by Michal Hocko, instead of adjusting memory_hotplug paths,
I have changed memmap_init_zone() to initialize struct pages beyond the
zone end (if zone end is not aligned with the section boundary).

Mikhail Zaslonko (1):
  mm, memory_hotplug: Initialize struct pages for the full memory
    section

 mm/page_alloc.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

-- 
2.16.4
