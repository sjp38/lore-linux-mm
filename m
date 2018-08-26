Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7F26B3D1B
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 18:16:12 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id k17-v6so530417pll.21
        for <linux-mm@kvack.org>; Sun, 26 Aug 2018 15:16:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t32-v6si345561pgl.484.2018.08.26.15.16.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 Aug 2018 15:16:11 -0700 (PDT)
Date: Sun, 26 Aug 2018 15:15:41 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: TLB flushes on fixmap changes
Message-ID: <20180826221541.GB30765@bombadil.infradead.org>
References: <8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com>
 <CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com>
 <20180826112341.f77a528763e297cbc36058fa@kernel.org>
 <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
 <CAGXu5j+xUbq_mu=2jvH2Vu+mviteZJqdPNTrxpaijwsuDdN-sw@mail.gmail.com>
 <952A64F0-90B3-4E2F-B410-7E20BE90D617@amacapital.net>
 <CAGXu5jKk+ELGsSXC8e3v67oo74BF9rP2HDqMHx1Sb17-0F-xZQ@mail.gmail.com>
 <DF353FDA-4A57-4F5E-A403-531DDA0DBC25@amacapital.net>
 <alpine.DEB.2.21.1808262212030.1195@nanos.tec.linutronix.de>
 <CAGXu5jJQGiGwQRBGuVrmhQqyUEfRUUSD6WYokc2xezExY9ZNUg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJQGiGwQRBGuVrmhQqyUEfRUUSD6WYokc2xezExY9ZNUg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@amacapital.net>, Andy Lutomirski <luto@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Sun, Aug 26, 2018 at 03:03:59PM -0700, Kees Cook wrote:
> I thought the point was that the implementation I suggested was
> NMI-proof? (And in reading Documentation/preempt-locking.txt it sounds
> like disabling interrupts is redundant to preempt_disable()? But I
> don't understand how; it looks like the preempt stuff is advisory?)

Oter way round; disabling interrupts implicitly disables preemption
