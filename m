Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C12B76B00DB
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 08:51:19 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id l18so16766101wgh.38
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:51:19 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id em19si44786881wjd.52.2014.11.13.05.51.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 05:51:18 -0800 (PST)
Date: Thu, 13 Nov 2014 14:51:07 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 08/11] x86, mpx: [new code] decode MPX instruction to
 get bound violation information
In-Reply-To: <20141112170509.AED2778F@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1411131448530.3935@nanos>
References: <20141112170443.B4BD0899@viggo.jf.intel.com> <20141112170509.AED2778F@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: hpa@zytor.com, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, dave.hansen@linux.intel.com

On Wed, 12 Nov 2014, Dave Hansen wrote:
> Changes from the old decoder:
>  * Use the generic decoder instead of custom functions.  Saved
>    ~70 lines of code overall.
>  * Remove insn->addr_bytes code (never used??)
>  * Make sure never to possibly overflow the regoff[] array, plus
>    check the register range correctly in 32 and 64-bit modes.
>  * Allow get_reg() to return an error and have mpx_get_addr_ref()
>    handle when it sees errors.
>  * Only call insn_get_*() near where we actually use the values
>    instead if trying to call them all at once.
>  * Handle short reads from copy_from_user() and check the actual
>    number of read bytes against what we expect from
>    insn_get_length().  If a read stops in the middle of an
>    instruction, we error out.
>  * Actually check the opcodes intead of ignoring them.
>  * Dynamically kzalloc() siginfo_t so we don't leak any stack
>    data.
>  * Detect and handle decoder failures instead of ignoring them.

Very nice work! It's easy to follow and the error handling of all
sorts is well thought out.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
