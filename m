Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD31280903
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 20:13:49 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j5so140316799pfb.3
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 17:13:49 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id w11si1351936pfd.17.2017.03.09.17.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 17:13:48 -0800 (PST)
Date: Fri, 10 Mar 2017 09:12:39 +0800
From: Ye Xiaolong <xiaolong.ye@intel.com>
Subject: Re: [kbuild-all] [PATCH 6/6] sysctl: Add global tunable mt_page_copy
Message-ID: <20170310011239.GF4705@yexl-desktop>
References: <201702172358.xrHUyT1e%fengguang.wu@intel.com>
 <fa0c0260-9b98-42fc-9268-6f0b9c9ff592@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <fa0c0260-9b98-42fc-9268-6f0b9c9ff592@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: kbuild test robot <lkp@intel.com>, haren@linux.vnet.ibm.com, mhocko@suse.com, srikar@linux.vnet.ibm.com, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu, vbabka@suse.cz, kbuild-all@01.org

On 03/08, Anshuman Khandual wrote:
>On 02/17/2017 09:00 PM, kbuild test robot wrote:
>> Hi Zi,
>> 
>> [auto build test ERROR on linus/master]
>> [also build test ERROR on v4.10-rc8 next-20170217]
>> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>> 
>> url:    https://github.com/0day-ci/linux/commits/Anshuman-Khandual/Enable-parallel-page-migration/20170217-200523
>> config: i386-randconfig-a0-02131010 (attached as .config)
>> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
>
>Though I dont have the same compiler, I am unable to reproduce this
>build failure exactly. The build fails but for a different symbol.

I think previous "undefined reference to `mt_page_copy'" error is due to kbuild
bot didn't set CONFIG_MIGRATION (see attached config in original mail) since it
is a randconfig test.

Thanks,
Xiaolong

>I have the following gcc version but does it really make a
>difference with respect to finding the symbol etc ?
>
>gcc (Ubuntu 4.9.2-10ubuntu13) 4.9.2
>
>
>mm/memory.c: In function a??copy_pmd_rangea??:
>mm/memory.c:1002:3: error: implicit declaration of function
>a??pmd_relateda?? [-Werror=implicit-function-declaration]
>   if (pmd_related(*src_pmd)) {
>   ^
>cc1: some warnings being treated as errors
>scripts/Makefile.build:294: recipe for target 'mm/memory.o' failed
>
>_______________________________________________
>kbuild-all mailing list
>kbuild-all@lists.01.org
>https://lists.01.org/mailman/listinfo/kbuild-all

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
