Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF7A08E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 04:14:59 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w15so36510788qtk.19
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 01:14:59 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q11si900217qvb.83.2019.01.01.01.14.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jan 2019 01:14:58 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x019EAue034711
	for <linux-mm@kvack.org>; Tue, 1 Jan 2019 04:14:58 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pr417ttfh-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 01 Jan 2019 04:14:58 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 1 Jan 2019 09:14:56 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [RFC][PATCH v2 10/21] mm: build separate zonelist for PMEM and DRAM node
In-Reply-To: <20181226133351.644607371@intel.com>
References: <20181226131446.330864849@intel.com> <20181226133351.644607371@intel.com>
Date: Tue, 01 Jan 2019 14:44:41 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87sgyc7n9a.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

Fengguang Wu <fengguang.wu@intel.com> writes:

> From: Fan Du <fan.du@intel.com>
>
> When allocate page, DRAM and PMEM node should better not fall back to
> each other. This allows migration code to explicitly control which type
> of node to allocate pages from.
>
> With this patch, PMEM NUMA node can only be used in 2 ways:
> - migrate in and out
> - numactl

Can we achieve this using nodemask? That way we don't tag nodes with
different properties such as DRAM/PMEM. We can then give the
flexibilility to the device init code to add the new memory nodes to
the right nodemask

-aneesh
