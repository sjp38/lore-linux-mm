Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DED10831ED
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:37:30 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b2so62017380pgc.6
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:37:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k15si3592656pfj.185.2017.03.08.07.37.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 07:37:30 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v28FYTWQ035198
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 10:37:29 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0b-001b2d01.pphosted.com with ESMTP id 292fxnxrgg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Mar 2017 10:37:28 -0500
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 8 Mar 2017 21:07:25 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay06.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v28FbMux9437226
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 21:07:22 +0530
Received: from d28av06.in.ibm.com (localhost [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v28FbKAQ004092
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 21:07:22 +0530
Subject: Re: [PATCH 6/6] sysctl: Add global tunable mt_page_copy
References: <201702172358.xrHUyT1e%fengguang.wu@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 8 Mar 2017 21:07:17 +0530
MIME-Version: 1.0
In-Reply-To: <201702172358.xrHUyT1e%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Message-Id: <fa0c0260-9b98-42fc-9268-6f0b9c9ff592@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

On 02/17/2017 09:00 PM, kbuild test robot wrote:
> Hi Zi,
> 
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.10-rc8 next-20170217]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Anshuman-Khandual/Enable-parallel-page-migration/20170217-200523
> config: i386-randconfig-a0-02131010 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901

Though I dont have the same compiler, I am unable to reproduce this
build failure exactly. The build fails but for a different symbol.
I have the following gcc version but does it really make a
difference with respect to finding the symbol etc ?

gcc (Ubuntu 4.9.2-10ubuntu13) 4.9.2


mm/memory.c: In function ?copy_pmd_range?:
mm/memory.c:1002:3: error: implicit declaration of function
?pmd_related? [-Werror=implicit-function-declaration]
   if (pmd_related(*src_pmd)) {
   ^
cc1: some warnings being treated as errors
scripts/Makefile.build:294: recipe for target 'mm/memory.o' failed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
