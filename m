Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83ACB6B04FE
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 03:06:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y206so2269325wmd.1
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 00:06:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k80si16682424wrc.540.2017.07.28.00.06.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 00:06:13 -0700 (PDT)
Date: Fri, 28 Jul 2017 09:06:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/3] mm/hugetlb: Allow arch to override and call the
 weak function
Message-ID: <20170728070611.GG2274@dhcp22.suse.cz>
References: <20170727061828.11406-1-aneesh.kumar@linux.vnet.ibm.com>
 <20170727130123.GE27766@dhcp22.suse.cz>
 <e963e910-1999-ddff-87cf-9e8c356fea82@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e963e910-1999-ddff-87cf-9e8c356fea82@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu 27-07-17 21:50:35, Aneesh Kumar K.V wrote:
> 
> 
> On 07/27/2017 06:31 PM, Michal Hocko wrote:
> >On Thu 27-07-17 11:48:26, Aneesh Kumar K.V wrote:
> >>For ppc64, we want to call this function when we are not running as guest.
> >
> >What does this mean?
> >
> 
> ppc64 guest (aka LPAR) support a different mechanism for hugetlb
> allocation/reservation. The LPAR management application called HMC can be
> used to reserve a set of hugepages and we pass the details of reserved pages
> via device tree to the guest. You can find the details in
> htab_dt_scan_hugepage_blocks() . We do the memblock_reserve of the range and
> later in the boot sequence, we just add the reserved range to
> huge_boot_pages.
> 
> For baremetal config (when we are not running as guest) we want to follow
> what other architecture does, that is look at the command line and do
> memblock allocation. Hence the need to call generic function
> __alloc_bootmem_huge_page() in that case.
> 
> I can add all these details in to the commit message if that makes it easy ?

It certainly helped me to understand the context much better. Thanks! As
you are patching a generic code this would be appropriate IMHO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
