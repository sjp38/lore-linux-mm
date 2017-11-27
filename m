Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3FE6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 17:39:50 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id e41so12742647itd.5
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:39:50 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id l193si14740938ith.28.2017.11.27.14.39.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 14:39:49 -0800 (PST)
Date: Mon, 27 Nov 2017 23:39:40 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/5] x86/mm/kaiser: Alternative ESPFIX
Message-ID: <20171127223940.eedtdizvjqclz4xc@hirez.programming.kicks-ass.net>
References: <20171127223110.479550152@infradead.org>
 <20171127223405.181647306@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127223405.181647306@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 11:31:11PM +0100, Peter Zijlstra wrote:
> Change the asm to do the CR3 switcheroo so we can remove the magic
> mappings.
> 
> Since RDI is unused after SWAPGS we can use it as a scratch reg for
> SWITCH_TO_KERNEL. And once we've computed the new RSP (in RAX) we no
> longer need RDI and can again use it as scratch reg for
> SWITCH_TO_USER.

Forgot to note; this passes tools/testing/selftests/x86/sigreturn_64.

> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
