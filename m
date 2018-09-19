Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id D63D78E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 06:55:27 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id r10-v6so4523058oti.19
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 03:55:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 90-v6si7269989otb.290.2018.09.19.03.55.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 03:55:26 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8JAt2VJ031773
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 06:55:26 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mkky2txb7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 06:55:25 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 19 Sep 2018 11:55:21 +0100
Date: Wed, 19 Sep 2018 13:55:12 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 03/29] mm: remove CONFIG_HAVE_MEMBLOCK
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-4-git-send-email-rppt@linux.vnet.ibm.com>
 <20180919100449.00006df9@huawei.com>
 <20180919103457.GA20545@rapoport-lnx>
 <20180919114507.000059f3@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180919114507.000059f3@huawei.com>
Message-Id: <20180919105511.GB20545@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linuxarm@huawei.com

On Wed, Sep 19, 2018 at 11:45:07AM +0100, Jonathan Cameron wrote:
> On Wed, 19 Sep 2018 13:34:57 +0300
> Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > Hi Jonathan,
> > 
> > On Wed, Sep 19, 2018 at 10:04:49AM +0100, Jonathan Cameron wrote:
> > > On Wed, 5 Sep 2018 18:59:18 +0300
> > > Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> > >   
> > > > All architecures use memblock for early memory management. There is no need
> > > > for the CONFIG_HAVE_MEMBLOCK configuration option.
> > > > 
> > > > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>  
> > > 
> > > Hi Mike,
> > > 
> > > A minor editing issue in here that is stopping boot on arm64 platforms with latest
> > > version of the mm tree.  
> > 
> > Can you please try the following patch:
> > 
> > 
> > From 079bd5d24a01df3df9500d0a33d89cb9f7da4588 Mon Sep 17 00:00:00 2001
> > From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > Date: Wed, 19 Sep 2018 13:29:27 +0300
> > Subject: [PATCH] of/fdt: fixup #ifdefs after removal of HAVE_MEMBLOCK config
> >  option
> > 
> > The removal of HAVE_MEMBLOCK configuration option, mistakenly dropped the
> > wrong #endif. This patch restores that #endif and removes the part that
> > should have been actually removed, starting from #else and up to the
> > correct #endif
> > 
> > Reported-by: Jonathan Cameron <jonathan.cameron@huawei.com>
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> Hi Mike,
> 
> That's identical to the local patch I'm carrying to fix this so looks good to me.
> 
> For what it's worth given you'll probably fold this into the larger patch.
> 
> Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Well, this is up to Andrew now, as the broken patch is already in the -mm
tree.
 
> Thanks for the quick reply.
> 
> Jonathan
> 
> > ---
> >  drivers/of/fdt.c | 21 +--------------------
> >  1 file changed, 1 insertion(+), 20 deletions(-)
> > 
> > diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> > index 48314e9..bb532aa 100644
> > --- a/drivers/of/fdt.c
> > +++ b/drivers/of/fdt.c
> > @@ -1119,6 +1119,7 @@ int __init early_init_dt_scan_chosen(unsigned long node, const char *uname,
> >  #endif
> >  #ifndef MAX_MEMBLOCK_ADDR
> >  #define MAX_MEMBLOCK_ADDR	((phys_addr_t)~0)
> > +#endif
> >  
> >  void __init __weak early_init_dt_add_memory_arch(u64 base, u64 size)
> >  {
> > @@ -1175,26 +1176,6 @@ int __init __weak early_init_dt_reserve_memory_arch(phys_addr_t base,
> >  	return memblock_reserve(base, size);
> >  }
> >  
> > -#else
> > -void __init __weak early_init_dt_add_memory_arch(u64 base, u64 size)
> > -{
> > -	WARN_ON(1);
> > -}
> > -
> > -int __init __weak early_init_dt_mark_hotplug_memory_arch(u64 base, u64 size)
> > -{
> > -	return -ENOSYS;
> > -}
> > -
> > -int __init __weak early_init_dt_reserve_memory_arch(phys_addr_t base,
> > -					phys_addr_t size, bool nomap)
> > -{
> > -	pr_err("Reserved memory not supported, ignoring range %pa - %pa%s\n",
> > -		  &base, &size, nomap ? " (nomap)" : "");
> > -	return -ENOSYS;
> > -}
> > -#endif
> > -
> >  static void * __init early_init_dt_alloc_memory_arch(u64 size, u64 align)
> >  {
> >  	return memblock_alloc(size, align);
> 
> 

-- 
Sincerely yours,
Mike.
