Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04A4D6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 08:23:48 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id b79so18683841wrd.19
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 05:23:47 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x23si11428955wma.79.2017.11.27.05.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 05:23:46 -0800 (PST)
Date: Mon, 27 Nov 2017 14:23:41 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] x86/mm/kaiser: Disable global pages by default with
 KAISER
In-Reply-To: <20171127132037.tqmnwchnmxp67n35@gmail.com>
Message-ID: <alpine.DEB.2.20.1711271423040.1799@nanos>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193105.02A90543@viggo.jf.intel.com> <1510688325.1080.1.camel@redhat.com> <20171126144842.7ojxbo5wsu44w4ti@gmail.com> <alpine.DEB.2.20.1711271236560.1799@nanos>
 <20171127132037.tqmnwchnmxp67n35@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bp@suse.de, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Mon, 27 Nov 2017, Ingo Molnar wrote:
> * Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Sun, 26 Nov 2017, Ingo Molnar wrote:
> > >  * Disable global pages for anything using the default
> > >  * __PAGE_KERNEL* macros.
> > >  *
> > >  * PGE will still be enabled and _PAGE_GLOBAL may still be used carefully
> > >  * for a few selected kernel mappings which must be visible to userspace,
> > >  * when KAISER is enabled, like the entry/exit code and data.
> > >  */
> > > #ifdef CONFIG_KAISER
> > > #define __PAGE_KERNEL_GLOBAL	0
> > > #else
> > > #define __PAGE_KERNEL_GLOBAL	_PAGE_GLOBAL
> > > #endif
> > > 
> > > ... and I've added your Reviewed-by tag which I assume now applies?
> > 
> > Ideally we replace the whole patch with the __supported_pte_mask one which
> > I posted as a delta patch.
> 
> Yeah, so I squashed these two patches:
> 
>   09d76fc407e0: x86/mm/kaiser: Disable global pages by default with KAISER
>   bac79112ee4a: x86/mm/kaiser: Simplify disabling of global pages
> 
> into a single patch, which results in the single patch below, with an updated 
> changelog that reflects the cleanups. I kept Dave's authorship and credited you 
> for the simplification.
> 
> Note that the squashed commit had some whitespace noise which I skipped, further 
> simplifying the patch.
> 
> Is it OK this way? If yes then I'll reshuffle the tree with this variant.

Yes.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
