Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id B24586B00A8
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 16:16:01 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id bs8so43979149wib.0
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 13:16:01 -0800 (PST)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id gw2si5565886wib.56.2015.02.18.13.15.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Feb 2015 13:15:59 -0800 (PST)
Received: by mail-wg0-f50.google.com with SMTP id l2so3600421wgh.9
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 13:15:59 -0800 (PST)
Date: Wed, 18 Feb 2015 22:15:55 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 6/7] x86, mm: Support huge I/O mappings on x86
Message-ID: <20150218211555.GA22696@gmail.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
 <1423521935-17454-7-git-send-email-toshi.kani@hp.com>
 <20150218204414.GA20943@gmail.com>
 <1424294020.17007.21.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424294020.17007.21.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com


* Toshi Kani <toshi.kani@hp.com> wrote:

> On Wed, 2015-02-18 at 21:44 +0100, Ingo Molnar wrote:
> > * Toshi Kani <toshi.kani@hp.com> wrote:
> > 
> > > This patch implements huge I/O mapping capability interfaces on x86.
> > 
> > > +#ifdef CONFIG_HUGE_IOMAP
> > > +#ifdef CONFIG_X86_64
> > > +#define IOREMAP_MAX_ORDER       (PUD_SHIFT)
> > > +#else
> > > +#define IOREMAP_MAX_ORDER       (PMD_SHIFT)
> > > +#endif
> > > +#endif  /* CONFIG_HUGE_IOMAP */
> > 
> > > +#ifdef CONFIG_HUGE_IOMAP
> > 
> > Hm, so why is there a Kconfig option for this? It just 
> > complicates things.
> > 
> > For example the kernel already defaults to mapping itself 
> > with as large mappings as possible, without a Kconfig entry 
> > for it. There's no reason to make this configurable - and 
> > quite a bit of complexity in the patches comes from this 
> > configurability.
> 
> This Kconfig option was added to disable this feature in 
> case there is an issue. [...]

If bugs are found then they should be fixed.

> [...]  That said, since the patchset also added a new 
> nohugeiomap boot option for the same purpose, I agree 
> that this Kconfig option can be removed.  So, I will 
> remove it in the next version.
> 
> An example of such case is with multiple MTRRs described 
> in patch 0/7.

So the multi-MTRR case should probably be detected and 
handled safely?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
