Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 950126B00A6
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 16:14:05 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id wo20so7059389obc.5
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 13:14:05 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id t19si2624025oey.97.2015.02.18.13.14.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Feb 2015 13:14:04 -0800 (PST)
Message-ID: <1424294020.17007.21.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 6/7] x86, mm: Support huge I/O mappings on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 18 Feb 2015 14:13:40 -0700
In-Reply-To: <20150218204414.GA20943@gmail.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
	 <1423521935-17454-7-git-send-email-toshi.kani@hp.com>
	 <20150218204414.GA20943@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com

On Wed, 2015-02-18 at 21:44 +0100, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > This patch implements huge I/O mapping capability interfaces on x86.
> 
> > +#ifdef CONFIG_HUGE_IOMAP
> > +#ifdef CONFIG_X86_64
> > +#define IOREMAP_MAX_ORDER       (PUD_SHIFT)
> > +#else
> > +#define IOREMAP_MAX_ORDER       (PMD_SHIFT)
> > +#endif
> > +#endif  /* CONFIG_HUGE_IOMAP */
> 
> > +#ifdef CONFIG_HUGE_IOMAP
> 
> Hm, so why is there a Kconfig option for this? It just 
> complicates things.
> 
> For example the kernel already defaults to mapping itself 
> with as large mappings as possible, without a Kconfig entry 
> for it. There's no reason to make this configurable - and 
> quite a bit of complexity in the patches comes from this 
> configurability.

This Kconfig option was added to disable this feature in case there is
an issue.  That said, since the patchset also added a new nohugeiomap
boot option for the same purpose, I agree that this Kconfig option can
be removed.  So, I will remove it in the next version.

An example of such case is with multiple MTRRs described in patch 0/7.
However, I believe it is very unlikely to have such platform/use-case,
and it can also be avoided by a driver creating a separate mapping for
each MTRR range. 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
