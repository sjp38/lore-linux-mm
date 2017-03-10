Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95D542808A9
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 07:11:25 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id o126so161795496pfb.2
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 04:11:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x3si2795722pfx.74.2017.03.10.04.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 04:11:24 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2AC9DLM094019
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 07:11:24 -0500
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2937e74njy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 07:11:24 -0500
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 10 Mar 2017 17:41:21 +0530
Received: from d28av08.in.ibm.com (d28av08.in.ibm.com [9.184.220.148])
	by d28relay09.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v2ACBIRN14483702
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 17:41:18 +0530
Received: from d28av08.in.ibm.com (localhost [127.0.0.1])
	by d28av08.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v2ACBGbu011454
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 17:41:17 +0530
Subject: Re: [kbuild-all] [PATCH 6/6] sysctl: Add global tunable mt_page_copy
References: <201702172358.xrHUyT1e%fengguang.wu@intel.com>
 <fa0c0260-9b98-42fc-9268-6f0b9c9ff592@linux.vnet.ibm.com>
 <20170310011239.GF4705@yexl-desktop>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 10 Mar 2017 17:41:14 +0530
MIME-Version: 1.0
In-Reply-To: <20170310011239.GF4705@yexl-desktop>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <d1cea9bd-feab-86f0-d76c-8df812848c0a@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ye Xiaolong <xiaolong.ye@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: kbuild test robot <lkp@intel.com>, haren@linux.vnet.ibm.com, mhocko@suse.com, srikar@linux.vnet.ibm.com, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu, vbabka@suse.cz, kbuild-all@01.org

On 03/10/2017 06:42 AM, Ye Xiaolong wrote:
> On 03/08, Anshuman Khandual wrote:
>> On 02/17/2017 09:00 PM, kbuild test robot wrote:
>>> Hi Zi,
>>>
>>> [auto build test ERROR on linus/master]
>>> [also build test ERROR on v4.10-rc8 next-20170217]
>>> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>>>
>>> url:    https://github.com/0day-ci/linux/commits/Anshuman-Khandual/Enable-parallel-page-migration/20170217-200523
>>> config: i386-randconfig-a0-02131010 (attached as .config)
>>> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
>> Though I dont have the same compiler, I am unable to reproduce this
>> build failure exactly. The build fails but for a different symbol.
> I think previous "undefined reference to `mt_page_copy'" error is due to kbuild
> bot didn't set CONFIG_MIGRATION (see attached config in original mail) since it
> is a randconfig test.

If CONFIG_MIGRATION is not set then mm/migrate.c never gets compiled
and the symbol 'mt_page_copy' is never exported for kernel/sysctl.c
based extern variable to use. Sure, will fix it by keeping all the
code in kernel/sysctl.c within CONFIG_MIGRATION config. Thanks for
pointing it out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
