Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 623856B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:48:53 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id r6so2736301itr.1
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 02:48:53 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 123si1060862iou.29.2017.11.29.02.48.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 02:48:52 -0800 (PST)
Date: Wed, 29 Nov 2017 11:48:41 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 4/6] x86/mm/kaiser: Support PCID without INVPCID
Message-ID: <20171129104841.63slqtfrrjwvyrfi@hirez.programming.kicks-ass.net>
References: <20171129103301.131535445@infradead.org>
 <20171129103512.819130098@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129103512.819130098@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andy Lutomirski <luto@amacapital.net>

On Wed, Nov 29, 2017 at 11:33:05AM +0100, Peter Zijlstra wrote:
> +DECLARE_PER_CPU(unsigned long, user_asid_flush_mask);

Ah, I meant to make that: DECLARE_BITMAP(TLB_NR_DYN_ASIDS)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
