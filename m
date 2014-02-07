Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA4C6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 16:15:32 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so3713500pab.10
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 13:15:32 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id oq9si6400531pac.93.2014.02.07.13.15.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 13:15:31 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so3699216pab.15
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 13:15:31 -0800 (PST)
Date: Fri, 7 Feb 2014 13:15:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 9/9] mm: Remove ifdef condition in include/linux/mm.h
In-Reply-To: <20140207210705.GB13604@jtriplet-mobl1>
Message-ID: <alpine.DEB.2.02.1402071314180.4212@chino.kir.corp.google.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <63adb3b97f2869d4c7e76d17ef4aa76b8cf599f3.1391167128.git.rashika.kheria@gmail.com> <alpine.DEB.2.02.1402071304080.4212@chino.kir.corp.google.com>
 <20140207210705.GB13604@jtriplet-mobl1>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Rashika Kheria <rashika.kheria@gmail.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jiang Liu <jiang.liu@huawei.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org

On Fri, 7 Feb 2014, Josh Triplett wrote:

> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > index 1cedd00..5f8348f 100644
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -1589,10 +1589,8 @@ static inline int __early_pfn_to_nid(unsigned long pfn)
> > >  #else
> > >  /* please see mm/page_alloc.c */
> > >  extern int __meminit early_pfn_to_nid(unsigned long pfn);
> > > -#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
> > >  /* there is a per-arch backend function. */
> > >  extern int __meminit __early_pfn_to_nid(unsigned long pfn);
> > > -#endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
> > >  #endif
> > >  
> > >  extern void set_dma_reserve(unsigned long new_dma_reserve);
> > 
> > Wouldn't it be better to just declare the __early_pfn_to_nid() in 
> > mm/page_alloc.c to be static?
> 
> Won't that break the ability to override that function in
> architecture-specific code (as arch/ia64/mm/numa.c does)?
> 

Why?  CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID should define where this function 
is defined so ia64 should have it set and the definition which I'm 
suggesting be static is only compiled when this is undefined in 
mm/page_alloc.c.  I'm not sure why we'd want to be messing with the 
declaration?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
