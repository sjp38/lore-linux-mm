Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C19A6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 17:47:12 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r23so17776653pfg.17
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:47:12 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e17si3318715pfi.388.2017.11.27.14.47.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 14:47:11 -0800 (PST)
Subject: Re: [PATCH 4/5] x86/mm/kaiser: Remove superfluous SWITCH_TO_KERNEL
References: <20171127223110.479550152@infradead.org>
 <20171127223405.329572992@infradead.org>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <b96a07a3-9fd5-f4c1-a4d5-433c590d006e@linux.intel.com>
Date: Mon, 27 Nov 2017 14:47:08 -0800
MIME-Version: 1.0
In-Reply-To: <20171127223405.329572992@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On 11/27/2017 02:31 PM, Peter Zijlstra wrote:
> We never use this code-path with KAISER enabled.
...
> @@ -201,14 +201,6 @@ ENTRY(entry_SYSCALL_64)
>  
>  	swapgs
>  	movq	%rsp, PER_CPU_VAR(rsp_scratch)
> -
> -	/*
> -	 * The kernel CR3 is needed to map the process stack, but we
> -	 * need a scratch register to be able to load CR3.  %rsp is
> -	 * clobberable right now, so use it as a scratch register.
> -	 * %rsp will look crazy here for a couple instructions.
> -	 */
> -	SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp
>  	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp

What's the mechanism that we use to switch between the two versions of
the SYSCALL entry?  It wasn't obvious from some grepping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
