Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 635D86B0261
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 06:49:36 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id 124so5268575wmv.1
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:49:36 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w5si7869691wre.263.2017.11.27.03.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 03:49:35 -0800 (PST)
Date: Mon, 27 Nov 2017 12:49:04 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch V2 2/5] x86/kaiser: Simplify disabling of global pages
In-Reply-To: <20171126232414.393912629@linutronix.de>
Message-ID: <alpine.DEB.2.20.1711271248000.1799@nanos>
References: <20171126231403.657575796@linutronix.de> <20171126232414.393912629@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, 27 Nov 2017, Thomas Gleixner wrote:
>  	/*
> @@ -179,11 +186,11 @@ static void __init probe_page_size_mask(
>  		cr4_set_bits_and_update_boot(X86_CR4_PSE);
>  
>  	/* Enable PGE if available */
> +	__supported_pte_mask |= _PAGE_GLOBAL;

Bah. Late night reject fixup wreckage. That wants to be

	__supported_pte_mask &= ~_PAGE_GLOBAL;

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
