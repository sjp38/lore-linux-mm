Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id AE7326B0036
	for <linux-mm@kvack.org>; Fri, 15 Aug 2014 07:44:24 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id i13so1941811qae.20
        for <linux-mm@kvack.org>; Fri, 15 Aug 2014 04:44:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b19si11469458qaw.25.2014.08.15.04.44.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Aug 2014 04:44:23 -0700 (PDT)
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: [PATCH V2 0/2] Prevent possible PTE corruption with /dev/mem mmap
Date: Fri, 15 Aug 2014 13:44:01 +0200
Message-Id: <1408103043-31015-1-git-send-email-fhrbata@redhat.com>
In-Reply-To: <1408025927-16826-1-git-send-email-fhrbata@redhat.com>
References: <1408025927-16826-1-git-send-email-fhrbata@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dave.hansen@intel.com, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com

Thanks to Dave Hansen for pointing out problems related to the pfn check in the
first version. I tried to fix it by adding a new arch_pfn_possible helper to
arch/x86/mm/physaddr.h. Please note that I'm not quite sure about the name and
the location(physaddr.h). Maybe we can keep the check directly in the
valid_mmap_phys_addr_range. I will leave this to a discussion and fix it if
required.

Question: Do we need the CONFIG_PHYS_ADDR_T_64BIT ifdef? The
boot_cpu_data.x86_phys_bits is set for all x86. So at this point it seems to me
more like an "optimization" for x86_32 or something kept from historic
reasons. I'm just curious and I of course may be missing something.

Many thanks

Frantisek Hrbata (2):
  x86: add arch_pfn_possible helper
  x86: add phys addr validity check for /dev/mem mmap

 arch/x86/include/asm/io.h |  4 ++++
 arch/x86/mm/mmap.c        | 12 ++++++++++++
 arch/x86/mm/physaddr.h    |  9 +++++++--
 3 files changed, 23 insertions(+), 2 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
