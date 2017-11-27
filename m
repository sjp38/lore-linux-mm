Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93C226B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 17:41:27 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f6so8927150pfe.16
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:41:27 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id c8si6171956pli.589.2017.11.27.14.41.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 14:41:26 -0800 (PST)
Subject: Re: [PATCH 1/5] x86/mm/kaiser: Alternative ESPFIX
References: <20171127223110.479550152@infradead.org>
 <20171127223405.181647306@infradead.org>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <7ba63732-8824-bb2b-d66b-bddd823de8e8@linux.intel.com>
Date: Mon, 27 Nov 2017 14:41:24 -0800
MIME-Version: 1.0
In-Reply-To: <20171127223405.181647306@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On 11/27/2017 02:31 PM, Peter Zijlstra wrote:
> Change the asm to do the CR3 switcheroo so we can remove the magic
> mappings.
> 
> Since RDI is unused after SWAPGS we can use it as a scratch reg for
> SWITCH_TO_KERNEL. And once we've computed the new RSP (in RAX) we no
> longer need RDI and can again use it as scratch reg for
> SWITCH_TO_USER.

This definitely looks like the right thing.  Either I missed something
obvious before, or Andy's entry rework made this much more obviously
correct to do the simple thing here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
