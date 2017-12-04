Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C52226B0273
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 15:30:01 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a141so4623566wma.8
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 12:30:01 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v11si5333993wrg.406.2017.12.04.12.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 12:30:00 -0800 (PST)
Date: Mon, 4 Dec 2017 21:29:45 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv3 1/5] x86/boot/compressed/64: Detect and handle 5-level
 paging at boot-time
In-Reply-To: <20171204124059.63515-2-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1712042112040.2198@nanos>
References: <20171204124059.63515-1-kirill.shutemov@linux.intel.com> <20171204124059.63515-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Mon, 4 Dec 2017, Kirill A. Shutemov wrote:

> This patch prepare decompression code to boot-time switching between 4-
> and 5-level paging.

This is the very wrong reason for tagging this commit stable.

> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: <stable@vger.kernel.org>	[4.14+]

Adding cc stable  requires a Fixes tag as well.

> +int l5_paging_required(void)
> +{
> +	/* Check i leaf 7 is supported. */

So you introduce the typo here and then you fix it in the next patch which
is the actual bug fix as an completely unrelated hunk.

-- a/arch/x86/boot/compressed/pgtable_64.c
+++ b/arch/x86/boot/compressed/pgtable_64.c
@@ -2,7 +2,7 @@
 
 int l5_paging_required(void)
 {
-       /* Check i leaf 7 is supported. */
+       /* Check if leaf 7 is supported. */

That's just careless and sloppy.

I fixed it up once more along with the lousy changelogs because this crap,
which you not even thought about addressing it when shoving your 5-level
support into 4.14 needs to be fixed.

I'm really tired of your sloppiness. You waste everyones time just by
ignoring feedback and continuing to do what you think is enough. Works for
me is _NOT_ enough for kernel development.

I'm not even looking at the rest of the series unless someone else has the
stomach to do so and sends a Reviewed-by.

Alternatively you can sit down and look at the changelogs and the code and
figure out whether it matches what I told you over and over. Once you think
it does, then please feel free to resend it, but be sure that I'm going to
apply the most restrictive crap filter on anything which comes from you
from now on.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
