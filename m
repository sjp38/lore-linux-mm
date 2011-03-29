Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 241C18D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 13:33:00 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1576541Ab1C2RcV (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 29 Mar 2011 19:32:21 +0200
Date: Tue, 29 Mar 2011 19:32:21 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH 2/3] mm: Add SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN() macro
Message-ID: <20110329173221.GB30387@router-fw-old.local.net-space.pl>
References: <20110328092412.GC13826@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1103281545220.7148@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103281545220.7148@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 28, 2011 at 03:46:27PM -0700, David Rientjes wrote:
> On Mon, 28 Mar 2011, Daniel Kiper wrote:
>
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 02ecb01..d342820 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -931,6 +931,9 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
> >  #define pfn_to_section_nr(pfn) ((pfn) >> PFN_SECTION_SHIFT)
> >  #define section_nr_to_pfn(sec) ((sec) << PFN_SECTION_SHIFT)
> >
> > +#define SECTION_ALIGN_UP(pfn)	(((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
> > +#define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
> > +
> >  #ifdef CONFIG_SPARSEMEM
> >
> >  /*
>
> These are only valid for CONFIG_SPARSEMEM, so they need to be defined 
> conditionally.

OK, however, I think that pfn_to_section_nr()/section_nr_to_pfn()
should be defined conditionally, too.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
