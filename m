Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 988CA6B0255
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:49:09 -0500 (EST)
Received: by wmww144 with SMTP id w144so41742439wmw.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:49:09 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id n16si5938416wjw.236.2015.12.08.10.49.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:49:08 -0800 (PST)
Date: Tue, 8 Dec 2015 19:48:19 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 30/34] x86, fpu: allow setting of XSAVE state
In-Reply-To: <20151204011506.7A3C77FA@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081948020.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011506.7A3C77FA@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> We want to modify the Protection Key rights inside the kernel, so
> we need to change PKRU's contents.  But, if we do a plain
> 'wrpkru', when we return to userspace we might do an XRSTOR and
> wipe out the kernel's 'wrpkru'.  So, we need to go after PKRU in
> the xsave buffer.
> 
> We do this by:
> 1. Ensuring that we have the XSAVE registers (fpregs) in the
>    kernel FPU buffer (fpstate)
> 2. Looking up the location of a given state in the buffer
> 3. Filling in the stat
> 4. Ensuring that the hardware knows that state is present there
>    (basically that the 'init optimization' is not in place).
> 5. Copying the newly-modified state back to the registers if
>    necessary.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
