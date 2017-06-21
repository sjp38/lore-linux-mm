Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 874796B03BC
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:26:34 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 77so15083119wrb.11
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 02:26:34 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f38si17644806wra.124.2017.06.21.02.26.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 02:26:33 -0700 (PDT)
Date: Wed, 21 Jun 2017 11:26:29 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 08/11] x86/mm: Disable PCID on 32-bit kernels
In-Reply-To: <d817b0638d5225c7ee5560f86e0b216dd9f76e9a.1498022414.git.luto@kernel.org>
Message-ID: <alpine.DEB.2.20.1706211122490.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <d817b0638d5225c7ee5560f86e0b216dd9f76e9a.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 20 Jun 2017, Andy Lutomirski wrote:
> 32-bit kernels on new hardware will see PCID in CPUID, but PCID can
> only be used in 64-bit mode.  Rather than making all PCID code
> conditional, just disable the feature on 32-bit builds.
> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
