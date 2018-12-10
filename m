Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07B0C8E0001
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 08:07:22 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i14so5230866edf.17
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 05:07:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u18si2952034edl.65.2018.12.10.05.07.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 05:07:20 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBAD5LYH045631
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 08:07:19 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p9ndt9se0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 08:07:18 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zaslonko@linux.ibm.com>;
	Mon, 10 Dec 2018 13:07:17 -0000
From: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Subject: [PATCH 0/1] Initialize struct pages for the full section
Date: Mon, 10 Dec 2018 14:07:11 +0100
Message-Id: <20181210130712.30148-1-zaslonko@linux.ibm.com>
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

 mm/page_alloc.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

-- 
2.16.4
