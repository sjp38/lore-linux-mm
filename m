Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id B067F6B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 02:49:14 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id j189so168521777vkc.3
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 23:49:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k3si20427034qkc.77.2016.09.05.23.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Sep 2016 23:49:13 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u866ljtc028451
	for <linux-mm@kvack.org>; Tue, 6 Sep 2016 02:49:13 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 259rhk0tkm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Sep 2016 02:49:12 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 6 Sep 2016 16:49:10 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 87E6D3578052
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 16:49:07 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u866n7FZ56033292
	for <linux-mm@kvack.org>; Tue, 6 Sep 2016 16:49:07 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u866n74h019833
	for <linux-mm@kvack.org>; Tue, 6 Sep 2016 16:49:07 +1000
Date: Tue, 06 Sep 2016 12:19:05 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 2/2] mm: Add sysfs interface to dump each node's zonelist
 information
References: <201609061410.GxOTG4KX%fengguang.wu@intel.com>
In-Reply-To: <201609061410.GxOTG4KX%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57CE66E1.1070105@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 09/06/2016 11:41 AM, kbuild test robot wrote:
> Hi Anshuman,
> 
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.8-rc5 next-20160905]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> [Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
> [Check https://git-scm.com/docs/git-format-patch for more information]
> 
> url:    https://github.com/0day-ci/linux/commits/Anshuman-Khandual/mm-Export-definition-of-zone_names-array-through-mmzone-h/20160906-133749
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: x86_64-randconfig-x013-201636 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    drivers/base/memory.c: In function 'dump_zonelists':
>>> >> drivers/base/memory.c:474:20: error: 'ZONELIST_NOFALLBACK' undeclared (first use in this function)
>         node_zonelists[ZONELIST_NOFALLBACK]);
>                        ^~~~~~~~~~~~~~~~~~~
>    drivers/base/memory.c:474:20: note: each undeclared identifier is reported only once for each function it appears in
> 
> vim +/ZONELIST_NOFALLBACK +474 drivers/base/memory.c
> 
>    468					node_zonelists[ZONELIST_FALLBACK]);
>    469			count += sprintf(buf + count, "[NODE (%d)]\n", node);
>    470			count += sprintf(buf + count, "\tZONELIST_FALLBACK\n");
>    471			count += dump_zonelist(buf + count, zonelist);
>    472	
>    473			zonelist = &(NODE_DATA(node)->
>  > 474					node_zonelists[ZONELIST_NOFALLBACK]);
>    475			count += sprintf(buf + count, "\tZONELIST_NOFALLBACK\n");

Missed the fact that ZONELIST_NOFALLBACK is valid only on CONFIG_NUMA
systems. Will fix and resend the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
