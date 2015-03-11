Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id A91B3900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 11:26:15 -0400 (EDT)
Received: by obcwp4 with SMTP id wp4so9577937obc.4
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 08:26:15 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id p10si2275930oeq.29.2015.03.11.08.26.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 08:26:15 -0700 (PDT)
Message-ID: <1426087526.17007.315.camel@misato.fc.hp.com>
Subject: Re: [PATCH 1/3] mm, x86: Document return values of mapping funcs
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 11 Mar 2015 09:25:26 -0600
In-Reply-To: <20150311063024.GB29788@gmail.com>
References: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
	 <1426018997-12936-2-git-send-email-toshi.kani@hp.com>
	 <20150311063024.GB29788@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "Elliott, Robert (Server Storage)" <Elliott@hp.com>, "pebolle@tiscali.nl" <pebolle@tiscali.nl>

On Wed, 2015-03-11 at 06:30 +0000, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > Documented the return values of KVA mapping functions,
> > pud_set_huge(), pmd_set_huge, pud_clear_huge() and
> > pmd_clear_huge().
> > 
> > Simplified the conditions to select HAVE_ARCH_HUGE_VMAP
> > in Kconfig since X86_PAE depends on X86_32.
> 
> Changelogs are not a diary, they are a story, generally written in the 
> present tense. 

Oh, I see. Thanks for the tip!

> So it should be something like:
> 
>   Document the return values of KVA mapping functions,
>   pud_set_huge(), pmd_set_huge, pud_clear_huge() and
>   pmd_clear_huge().
> 
>   Simplify the conditions to select HAVE_ARCH_HUGE_VMAP
>   in the Kconfig, since X86_PAE depends on X86_32.
> 
> (also note the slight fixes I made to the text.)

Updated with the descriptions above.

> > There is no functinal change in this patch.
> 
> Typo.

Fixed.

> > +/**
> > + * pud_set_huge - setup kernel PUD mapping
> > + *
> > + * MTRRs can override PAT memory types with a 4KB granularity.  Therefore,
> 
> s/with a/with

Fixed.

> > + * it does not set up a huge page when the range is covered by non-WB type
> > + * of MTRRs.  0xFF indicates that MTRRs are disabled.
> > + *
> > + * Return 1 on success, and 0 on no-operation.
> 
> What is a 'no-operation'?
> 
> I suspect you want:
> 
>     * Returns 1 on success, and 0 when no PUD was set.

Yes, that's what it meant to say.

> > +/**
> > + * pmd_set_huge - setup kernel PMD mapping
> > + *
> > + * MTRRs can override PAT memory types with a 4KB granularity.  Therefore,
> > + * it does not set up a huge page when the range is covered by non-WB type
> > + * of MTRRs.  0xFF indicates that MTRRs are disabled.
> > + *
> > + * Return 1 on success, and 0 on no-operation.
> 
> Ditto (and the rest of the patch).

Updated all functions. I changed pud_clear_huge()'s description to:  

 * Return 1 on success, and 0 when no PUD map was found.

Thanks!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
