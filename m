Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CD1076B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 11:12:03 -0400 (EDT)
Received: by qwf7 with SMTP id 7so649597qwf.14
        for <linux-mm@kvack.org>; Thu, 09 Sep 2010 08:10:35 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
Date: Thu, 9 Sep 2010 17:10:34 +0200
Message-ID: <AANLkTi=uzLJxDbd+uJAww-b5aP10gd8gbGVG19HS46ue@mail.gmail.com>
Subject: mm/Kconfig: warning: (COMPACTION && EXPERIMENTAL && HUGETLB_PAGE &&
 MMU) selects MIGRATION which has unmet direct dependencies (NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE)
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

while build latest 2.6.36-rc3 I get this warning:

[ build.log]
...
warning: (COMPACTION && EXPERIMENTAL && HUGETLB_PAGE && MMU) selects
MIGRATION which has unmet direct dependencies (NUMA ||
ARCH_ENABLE_MEMORY_HOTREMOVE)
...

Here the excerpt of...

[ mm/Kconfig ]
...
# support for memory compaction
config COMPACTION
        bool "Allow for memory compaction"
        select MIGRATION
        depends on EXPERIMENTAL && HUGETLB_PAGE && MMU
        help
          Allows the compaction of memory for the allocation of huge pages.
...

I have set the following kernel-config parameters:

$ egrep 'COMPACTION|HUGETLB_PAGE|MMU|MIGRATION|NUMA|ARCH_ENABLE_MEMORY_HOTREMOVE'
linux-2.6.36-rc3/debian/build/build_i386_none_686/.config
CONFIG_MMU=y
# CONFIG_IOMMU_HELPER is not set
CONFIG_IOMMU_API=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_MMU_NOTIFIER=y
CONFIG_HUGETLB_PAGE=y
# CONFIG_IOMMU_STRESS is not set

Looks like I have no NUMA or ARCH_ENABLE_MEMORY_HOTREMOVE set.

Ok, it is a *warning*...

Kind Regards,
- Sedat -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
