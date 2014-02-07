Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id C31806B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 16:07:14 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id m20so6852952qcx.37
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 13:07:14 -0800 (PST)
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [2001:4b98:c:538::197])
        by mx.google.com with ESMTPS id 8si4493467qak.162.2014.02.07.13.07.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 13:07:14 -0800 (PST)
Date: Fri, 7 Feb 2014 13:07:05 -0800
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 9/9] mm: Remove ifdef condition in include/linux/mm.h
Message-ID: <20140207210705.GB13604@jtriplet-mobl1>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
 <63adb3b97f2869d4c7e76d17ef4aa76b8cf599f3.1391167128.git.rashika.kheria@gmail.com>
 <alpine.DEB.2.02.1402071304080.4212@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402071304080.4212@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Rashika Kheria <rashika.kheria@gmail.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jiang Liu <jiang.liu@huawei.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org

On Fri, Feb 07, 2014 at 01:04:47PM -0800, David Rientjes wrote:
> On Fri, 7 Feb 2014, Rashika Kheria wrote:
> 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 1cedd00..5f8348f 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1589,10 +1589,8 @@ static inline int __early_pfn_to_nid(unsigned long pfn)
> >  #else
> >  /* please see mm/page_alloc.c */
> >  extern int __meminit early_pfn_to_nid(unsigned long pfn);
> > -#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
> >  /* there is a per-arch backend function. */
> >  extern int __meminit __early_pfn_to_nid(unsigned long pfn);
> > -#endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
> >  #endif
> >  
> >  extern void set_dma_reserve(unsigned long new_dma_reserve);
> 
> Wouldn't it be better to just declare the __early_pfn_to_nid() in 
> mm/page_alloc.c to be static?

Won't that break the ability to override that function in
architecture-specific code (as arch/ia64/mm/numa.c does)?

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
