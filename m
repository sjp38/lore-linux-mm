Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id CAF906B03B4
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 04:37:16 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id w15so162269plp.14
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 01:37:16 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v77si1751622pfa.223.2017.12.06.01.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 01:37:11 -0800 (PST)
Date: Wed, 6 Dec 2017 10:37:05 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: x86 TLB flushing: INVPCID vs. deferred CR3 write
Message-ID: <20171206093705.y74zuyexf44sl6n4@hirez.programming.kicks-ass.net>
References: <3062e486-3539-8a1f-5724-16199420be71@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3062e486-3539-8a1f-5724-16199420be71@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "Kleen, Andi" <andi.kleen@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Dec 05, 2017 at 05:27:31PM -0800, Dave Hansen wrote:
> tl;dr: Kernels with pagetable isolation using INVPCID compile kernels
> 0.58% faster than using the deferred CR3 write.  This tends to say that
> we should leave things as-is and keep using INVPCID, but it's far from
> definitive.

Much appreciated, thanks Dave!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
