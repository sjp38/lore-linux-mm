Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id B10BD6B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 18:38:32 -0500 (EST)
Received: by obcuz6 with SMTP id uz6so10482065obc.9
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 15:38:32 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id n203si2993505oia.44.2015.03.04.15.38.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 15:38:32 -0800 (PST)
Message-ID: <1425512272.17007.272.camel@misato.fc.hp.com>
Subject: Re: [PATCH v3 6/6 UPDATE] x86, mm: Support huge KVA mappings on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 04 Mar 2015 16:37:52 -0700
In-Reply-To: <1425511871.2090.65.camel@tiscali.nl>
References: <1425426480-10600-1-git-send-email-toshi.kani@hp.com>
	 <1425511871.2090.65.camel@tiscali.nl>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Bolle <pebolle@tiscali.nl>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com

On Thu, 2015-03-05 at 00:31 +0100, Paul Bolle wrote:
> Toshi Kani schreef op di 03-03-2015 om 16:48 [-0700]:
> > --- a/arch/x86/Kconfig
> > +++ b/arch/x86/Kconfig
> > @@ -99,6 +99,7 @@ config X86
> >  	select IRQ_FORCED_THREADING
> >  	select HAVE_BPF_JIT if X86_64
> >  	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
> > +	select HAVE_ARCH_HUGE_VMAP if X86_64 || (X86_32 && X86_PAE)
> 
> Minor nit: X86_PAE depends on X86_32, so I think this could be just
>     select HAVE_ARCH_HUGE_VMAP if X86_64 || X86_PAE

Right.  I will update in the next version.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
