Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id EBE6E6B0257
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:30:00 -0500 (EST)
Received: by wmec201 with SMTP id c201so41257422wme.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:30:00 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id z8si32055532wmg.102.2015.12.08.10.29.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:30:00 -0800 (PST)
Date: Tue, 8 Dec 2015 19:29:10 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 10/34] x86, pkeys: arch-specific protection bitsy
In-Reply-To: <56671C15.10304@sr71.net>
Message-ID: <alpine.DEB.2.11.1512081928010.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011438.E50D1498@viggo.jf.intel.com> <alpine.DEB.2.11.1512081523180.3595@nanos> <566706A1.3040906@sr71.net> <alpine.DEB.2.11.1512081817160.3595@nanos> <56671C15.10304@sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Tue, 8 Dec 2015, Dave Hansen wrote:

> Here's how it looks with the suggested modifications.
> 
> Whatever compiler wonkiness I was seeing is gone now, so I've used the
> most straightforward version of the shifts.

> +        * gcc generates better code if we do this rather than:
> +        * pkey = (flags & mask) >> shift
> +        */
> +       pkey = (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;

ROTFL!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
