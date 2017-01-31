Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D84506B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 00:49:05 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d123so237972921pfd.0
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 21:49:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d17si10354793pgh.312.2017.01.30.21.49.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 21:49:05 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0V5hP9C076943
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 00:49:04 -0500
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com [125.16.236.1])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28acreprq4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 00:49:04 -0500
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 31 Jan 2017 11:19:00 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id E6B06125801A
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 11:20:43 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0V5mw6N37879840
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 11:18:58 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0V5mvje020770
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 11:18:58 +0530
Subject: Re: [RFC V2 00/12] Define coherent device memory node
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 31 Jan 2017 11:18:49 +0530
MIME-Version: 1.0
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <1e57493b-1981-7c36-612d-3ddaf6ca88b7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

Hello Dave/Jerome/Mel,

Here is the overall layout of the functions I am trying to put together
through this patch series.

(1) Define CDM from core VM and kernel perspective

(2) Isolation/Special consideration for HugeTLB allocations

(3) Isolation/Special consideration for buddy allocations

	(a) Zonelist modification based isolation (proposed)
	(b) Cpuset modification based isolation	  (proposed)
	(c) Buddy modification based isolation	  (working)

(4) Define VMA containing CDM memory with a new flag VM_CDM

(5) Special consideration for VM_CDM marked VMAs

	(a) Special consideration for auto NUMA
	(b) Special consideration for KSM

Is there are any other area which needs to be taken care of before CDM
node can be represented completely inside the kernel ?

Regards
Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
