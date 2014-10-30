Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 732A690008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 05:07:41 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id p10so4744037pdj.19
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 02:07:41 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id zt7si6074005pbc.129.2014.10.30.02.07.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 02:07:40 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 30 Oct 2014 14:37:33 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 3DEB71258048
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 14:37:25 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9U97qYH59310258
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 14:37:53 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9U97IrE006925
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 14:37:19 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [mmotm:master 122/249] arch/arm/include/asm/pgtable.h:184:0: warning: "pgd_huge" redefined
In-Reply-To: <201410300658.7dG5Kjhu%fengguang.wu@intel.com>
References: <201410300658.7dG5Kjhu%fengguang.wu@intel.com>
Date: Thu, 30 Oct 2014 14:37:16 +0530
Message-ID: <87ioj27wor.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

kbuild test robot <fengguang.wu@intel.com> writes:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   7207a315977b07013f25ae9a3c1f8168facb6343
> commit: 208a47487f7214b16bef56aac912d26b60a43f9a [122/249] mm: update generic gup implementation to handle hugepage directory
> config: arm-omap2plus_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 208a47487f7214b16bef56aac912d26b60a43f9a
>   # save the attached .config to linux build tree
>   make.cross ARCH=arm 
>
> All warnings:
>
>    In file included from include/linux/mm.h:52:0,
>                     from mm/gup.c:7:
>>> arch/arm/include/asm/pgtable.h:184:0: warning: "pgd_huge" redefined
>     #define pgd_huge(pgd)  (0)
>     ^
>    In file included from mm/gup.c:6:0:
>    include/linux/hugetlb.h:183:0: note: this is the location of the previous definition
>     #define pgd_huge(x) 0
>     ^
>    In file included from include/linux/mm.h:52:0,
>                     from mm/gup.c:7:
>>> arch/arm/include/asm/pgtable.h:184:0: warning: "pgd_huge" redefined
>     #define pgd_huge(pgd)  (0)
>     ^
>    In file included from mm/gup.c:6:0:
>    include/linux/hugetlb.h:183:0: note: this is the location of the previous definition
>     #define pgd_huge(x) 0
>     ^
>

Should be fixed by.
http://mid.gmane.org/1414570785-18966-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com
IIUC the changes are going via powerpc tree. So not sure how it gets updated.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
