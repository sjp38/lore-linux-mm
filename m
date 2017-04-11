Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 94B016B03A0
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 07:28:50 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c55so11647755wrc.22
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 04:28:50 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id f25si11468971wrf.78.2017.04.11.04.28.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 04:28:49 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id d79so14361786wmi.2
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 04:28:49 -0700 (PDT)
Date: Tue, 11 Apr 2017 13:28:45 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/8] x86/boot/64: Add support of additional page table
 level during early boot
Message-ID: <20170411112845.GA15212@gmail.com>
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
 <20170406140106.78087-4-kirill.shutemov@linux.intel.com>
 <20170411070203.GA14621@gmail.com>
 <20170411105106.4zgbzuu4s4267zyv@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170411105106.4zgbzuu4s4267zyv@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Tue, Apr 11, 2017 at 09:02:03AM +0200, Ingo Molnar wrote:
> > I realize that you had difficulties converting this to C, but it's not going to 
> > get any easier in the future either, with one more paging mode/level added!
> > 
> > If you are stuck on where it breaks I'd suggest doing it gradually: first add a 
> > trivial .c, build and link it in and call it separately. Then once that works, 
> > move functionality from asm to C step by step and test it at every step.
> 
> I've described the specific issue with converting this code to C in cover
> letter: how to make compiler to generate 32-bit code for a specific
> function or translation unit, without breaking linking afterwards (-m32
> break it).

Have you tried putting it into a separate .c file, and building it 32-bit?

I think arch/x86/entry/vdso/Makefile contains an example of how to build 32-bit 
code even on 64-bit kernels.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
