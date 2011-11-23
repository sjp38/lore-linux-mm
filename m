Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EC7A26B00BE
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 22:19:05 -0500 (EST)
Subject: Re: [patch v2 3/4]thp: add tlb_remove_pmd_tlb_entry
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20111122150758.b05d90d9.akpm@linux-foundation.org>
References: <1321340658.22361.296.camel@sli10-conroe>
	 <20111122150758.b05d90d9.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Nov 2011 11:29:30 +0800
Message-ID: <1322018970.22361.343.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, 2011-11-23 at 07:07 +0800, Andrew Morton wrote:
> On Tue, 15 Nov 2011 15:04:18 +0800
> Shaohua Li <shaohua.li@intel.com> wrote:
> 
> > --- linux.orig/include/asm-generic/tlb.h	2011-11-15 09:39:11.000000000 +0800
> > +++ linux/include/asm-generic/tlb.h	2011-11-15 09:39:23.000000000 +0800
> > @@ -139,6 +139,20 @@ static inline void tlb_remove_page(struc
> >  		__tlb_remove_tlb_entry(tlb, ptep, address);	\
> >  	} while (0)
> >  
> > +/**
> > + * tlb_remove_pmd_tlb_entry - remember a pmd mapping for later tlb invalidation
> > + * This is a nop so far, because only x86 needs it.
> > + */
> > +#ifndef __tlb_remove_pmd_tlb_entry
> > +#define __tlb_remove_pmd_tlb_entry(tlb, pmdp, address) do {} while (0)
> > +#endif
> > +
> > +#define tlb_remove_pmd_tlb_entry(tlb, pmdp, address)		\
> > +	do {							\
> > +		tlb->need_flush = 1;				\
> > +		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);	\
> > +	} while (0)
> > +
> 
> Is there any reason why we cannot implement tlb_remove_pmd_tlb_entry()
> as a nice, typesafe C function?
no particular reason. I just followed tlb_remove_tlb_entry. all existing
codes in the file are not c function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
