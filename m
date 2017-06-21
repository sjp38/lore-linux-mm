Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A79E6B03F5
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:40:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z81so6043249wrc.2
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 06:40:08 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id e27si5874281wrc.304.2017.06.21.06.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 06:40:07 -0700 (PDT)
Date: Wed, 21 Jun 2017 15:40:01 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 10/11] x86/mm: Enable CR4.PCIDE on supported systems
In-Reply-To: <alpine.DEB.2.20.1706211127460.2328@nanos>
Message-ID: <alpine.DEB.2.20.1706211539080.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <57c1d18b1c11f9bc9a3bcf8bdee38033415e1a13.1498022414.git.luto@kernel.org> <alpine.DEB.2.20.1706211127460.2328@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Wed, 21 Jun 2017, Thomas Gleixner wrote:

> On Tue, 20 Jun 2017, Andy Lutomirski wrote:
> > +	/* Set up PCID */
> > +	if (cpu_has(c, X86_FEATURE_PCID)) {
> > +		if (cpu_has(c, X86_FEATURE_PGE)) {
> > +			cr4_set_bits(X86_CR4_PCIDE);
> 
> So I assume that you made sure that the PCID bits in CR3 are zero under all
> circumstances as setting PCIDE would cause a #GP if not.

And what happens on kexec etc? We need to reset the asid and PCIDE I assume.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
