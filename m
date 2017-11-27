Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5566B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 06:38:02 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id y186so17855300qky.20
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:38:02 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b193si12604251wmd.4.2017.11.27.03.38.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 03:38:01 -0800 (PST)
Date: Mon, 27 Nov 2017 12:37:52 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 04/30] x86, kaiser: disable global pages by default with
 KAISER
In-Reply-To: <20171126144842.7ojxbo5wsu44w4ti@gmail.com>
Message-ID: <alpine.DEB.2.20.1711271236560.1799@nanos>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193105.02A90543@viggo.jf.intel.com> <1510688325.1080.1.camel@redhat.com> <20171126144842.7ojxbo5wsu44w4ti@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bp@suse.de, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Sun, 26 Nov 2017, Ingo Molnar wrote:
>  * Disable global pages for anything using the default
>  * __PAGE_KERNEL* macros.
>  *
>  * PGE will still be enabled and _PAGE_GLOBAL may still be used carefully
>  * for a few selected kernel mappings which must be visible to userspace,
>  * when KAISER is enabled, like the entry/exit code and data.
>  */
> #ifdef CONFIG_KAISER
> #define __PAGE_KERNEL_GLOBAL	0
> #else
> #define __PAGE_KERNEL_GLOBAL	_PAGE_GLOBAL
> #endif
> 
> ... and I've added your Reviewed-by tag which I assume now applies?

Ideally we replace the whole patch with the __supported_pte_mask one which
I posted as a delta patch.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
