Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id AB4DB6B0037
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 14:32:33 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so1304261pdi.5
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 11:32:32 -0700 (PDT)
Date: Wed, 2 Oct 2013 20:31:55 +0200
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: Re: [RESEND PATCH] x86: add phys addr validity check for /dev/mem
 mmap
Message-ID: <20131002183155.GA2975@localhost.localdomain>
Reply-To: Frantisek Hrbata <fhrbata@redhat.com>
References: <20131002160514.GA25471@localhost.localdomain>
 <524C5BFB.5050501@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <524C5BFB.5050501@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dave.hansen@intel.com

On Wed, Oct 02, 2013 at 10:46:35AM -0700, H. Peter Anvin wrote:
> On 10/02/2013 09:05 AM, Frantisek Hrbata wrote:
> > +
> > +int valid_phys_addr_range(phys_addr_t addr, size_t count)
> > +{
> > +	return addr + count <= __pa(high_memory);
> > +}
> > +
> > +int valid_mmap_phys_addr_range(unsigned long pfn, size_t count)
> > +{
> > +	resource_size_t addr = (pfn << PAGE_SHIFT) + count;
> > +	return phys_addr_valid(addr);
> > +}
> > 
> 
> The latter has overflow problems.

Could you please specify what overflow problems do you mean?

> 
> The former I realize matches the current /dev/mem, but it is still just
> plain wrong in multiple ways.

I guess that you are talking about /dev/mem implementation generelly, because
this patch is exactly the same as the first one. All I'm trying to do here is to
fix this simple problem, which was reported by a customer, using IMHO the least
invasive way. Anyway is there any description what is wrong with /dev/mem
implementation? Maybe I can try to take a look.

Many thanks

> 
> 	-hpa
> 

-- 
Frantisek Hrbata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
