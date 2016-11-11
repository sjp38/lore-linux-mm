Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 20BB86B026C
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 23:12:41 -0500 (EST)
Received: by mail-pa0-f70.google.com with SMTP id hc3so8439058pac.4
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 20:12:41 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d130si8105440pfg.150.2016.11.10.20.12.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 20:12:40 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAB48SEw096400
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 23:12:39 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26n193k3r5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 23:12:39 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 11 Nov 2016 14:12:36 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C50DA2CE8059
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 15:12:32 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAB4CWqL43974836
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 15:12:32 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAB4CWmY022121
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 15:12:32 +1100
Subject: Re: [PATCH] mm: add ZONE_DEVICE statistics to smaps
References: <147881591739.39198.1358237993213024627.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2016 09:42:18 +0530
MIME-Version: 1.0
In-Reply-To: <147881591739.39198.1358237993213024627.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <58254522.70008@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Dave Hansen <dave.hansen@intel.com>, linux-nvdimm@lists.01.org, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/11/2016 03:41 AM, Dan Williams wrote:
> ZONE_DEVICE pages are mapped into a process via the filesystem-dax and
> device-dax mechanisms.  There are also proposals to use ZONE_DEVICE
> pages for other usages outside of dax.  Add statistics to smaps so
> applications can debug that they are obtaining the mappings they expect,
> or otherwise accounting them.

This might also help when we will have ZONE_DEVICE based solution for
HMM based device memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
