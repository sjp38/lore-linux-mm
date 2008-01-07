Received: by wa-out-1112.google.com with SMTP id m33so12286223wag.8
        for <linux-mm@kvack.org>; Mon, 07 Jan 2008 14:52:04 -0800 (PST)
Message-ID: <6934efce0801071452q9011f1cnfa16cef364c13541@mail.gmail.com>
Date: Mon, 7 Jan 2008 14:52:04 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [rfc][patch] mm: use a pte bit to flag normal pages
In-Reply-To: <20080107194543.GA2788@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071221104701.GE28484@wotan.suse.de>
	 <OFEC52C590.33A28896-ONC12573B8.0069F07E-C12573B8.006B1A41@de.ibm.com>
	 <20080107044355.GA11222@wotan.suse.de>
	 <20080107103028.GA9325@flint.arm.linux.org.uk>
	 <6934efce0801071049u546005e7t7da4311cc0611ccd@mail.gmail.com>
	 <20080107194543.GA2788@flint.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, carsteno@linux.vnet.ibm.com, Heiko Carstens <h.carstens@de.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Currently, Linux is able to setup mappings in kernel space to cover
> any combination of settings.  However, userspace is much more limited
> because we don't carry the additional bits around in the Linux version
> of the PTE - and as such shared mmaps on some systems can end up locking
> the CPU.
>
> A few attempts have been made at solving these without using the
> additional PTE bits, but they've been less that robust.

Do these new ARM implementations use more bits than most archs?

Most ARM implementations can spare a PTE bit for this, right?  Is the
use of these 3 extra bits to cover a few buggy processors or is this
caused by consolidating the needs of widely differing architectures?

I just can't get over the idea that you _have_ use up all available
bits.  Oh well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
