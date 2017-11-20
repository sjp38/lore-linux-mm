Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B5C956B0033
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 15:47:08 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y42so6529249wrd.23
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:47:08 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u10si5675589wru.237.2017.11.20.12.47.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 12:47:07 -0800 (PST)
Date: Mon, 20 Nov 2017 21:47:04 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 20/30] x86, mm: remove hard-coded ASID limit checks
In-Reply-To: <20171110193144.0376C2CC@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1711202144360.2348@nanos>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193144.0376C2CC@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Fri, 10 Nov 2017, Dave Hansen wrote:
>  
> +/* There are 12 bits of space for ASIDS in CR3 */
> +#define CR3_HW_ASID_BITS 12
> +/* When enabled, KAISER consumes a single bit for user/kernel switches */
> +#define KAISER_CONSUMED_ASID_BITS 0
> +
> +#define CR3_AVAIL_ASID_BITS (CR3_HW_ASID_BITS-KAISER_CONSUMED_ASID_BITS)

Spaces around '-' please. Same for other operators.

> +/*
> + * ASIDs are zero-based: 0->MAX_AVAIL_ASID are valid.  -1 below
> + * to account for them being zero-absed.  Another -1 is because ASID 0

s/absed/based/

> + * is reserved for use by non-PCID-aware users.
> + */
> +#define MAX_ASID_AVAILABLE ((1<<CR3_AVAIL_ASID_BITS) - 2)
> +
>  /*

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
