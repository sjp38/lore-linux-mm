Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B14576B026A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 08:32:21 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 29so11571473lfv.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 05:32:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g16si24973853wjs.145.2016.09.07.05.32.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 05:32:20 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u87CSU2H072648
	for <linux-mm@kvack.org>; Wed, 7 Sep 2016 08:32:19 -0400
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25a2cvdyh3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Sep 2016 08:32:17 -0400
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 7 Sep 2016 18:02:14 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 2AB55125805B
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 18:02:20 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u87CWCTf24772858
	for <linux-mm@kvack.org>; Wed, 7 Sep 2016 18:02:12 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u87CW97p011986
	for <linux-mm@kvack.org>; Wed, 7 Sep 2016 18:02:11 +0530
Date: Wed, 07 Sep 2016 18:02:08 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3] mm: Add sysfs interface to dump each node's zonelist
 information
References: <201609061710.F0GoBXOd%fengguang.wu@intel.com>
In-Reply-To: <201609061710.F0GoBXOd%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57D008C8.1040107@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 09/06/2016 02:35 PM, kbuild test robot wrote:
> Hi Anshuman,
> 
> [auto build test ERROR on driver-core/driver-core-testing]
> [also build test ERROR on v4.8-rc5 next-20160906]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> [Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
> [Check https://git-scm.com/docs/git-format-patch for more information]
> 
> url:    https://github.com/0day-ci/linux/commits/Anshuman-Khandual/mm-Add-sysfs-interface-to-dump-each-node-s-zonelist-information/20160906-163752
> config: x86_64-randconfig-x019-201636 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 

I am not able to reproduce this build failure with Fedora 24
and gcc (GCC) 6.1.1 20160621 on a x86 laptop. Maybe adding
mmzone.h into page_alloc.c will be enough to just take care
any issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
