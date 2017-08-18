Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D5BB96B025F
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 08:51:03 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 123so168665003pga.5
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 05:51:03 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id f34si3838341ple.481.2017.08.18.05.51.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 Aug 2017 05:51:02 -0700 (PDT)
In-Reply-To: <20170728050127.28338-1-aneesh.kumar@linux.vnet.ibm.com>
From: Michael Ellerman <patch-notifications@ellerman.id.au>
Subject: Re: [v4, 1/3] mm/hugetlb: Allow arch to override and call the weak function
Message-Id: <3xYjcf4rldz9t30@ozlabs.org>
Date: Fri, 18 Aug 2017 22:50:58 +1000 (AEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Fri, 2017-07-28 at 05:01:25 UTC, "Aneesh Kumar K.V" wrote:
> When running in guest mode ppc64 supports a different mechanism for hugetlb
> allocation/reservation. The LPAR management application called HMC can
> be used to reserve a set of hugepages and we pass the details of
> reserved pages via device tree to the guest. (more details in
> htab_dt_scan_hugepage_blocks()) . We do the memblock_reserve of the range
> and later in the boot sequence, we add the reserved range to huge_boot_pages.
> 
> But to enable 16G hugetlb on baremetal config (when we are not running as guest)
> we want to do memblock reservation during boot. Generic code already does this
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Series applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/e24a1307ba1f99fc62a0bd61d5e87f

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
