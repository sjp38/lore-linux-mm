Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA41D6B0038
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 16:15:20 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g80so10825470wrd.17
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 13:15:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z12sor4289475edm.42.2017.12.04.13.15.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Dec 2017 13:15:19 -0800 (PST)
Date: Tue, 5 Dec 2017 00:15:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 1/5] x86/boot/compressed/64: Detect and handle 5-level
 paging at boot-time
Message-ID: <20171204211517.nss6cn5llroehyts@node.shutemov.name>
References: <20171204124059.63515-1-kirill.shutemov@linux.intel.com>
 <20171204124059.63515-2-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.20.1712042112040.2198@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1712042112040.2198@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Mon, Dec 04, 2017 at 09:29:45PM +0100, Thomas Gleixner wrote:
> On Mon, 4 Dec 2017, Kirill A. Shutemov wrote:
> 
> > This patch prepare decompression code to boot-time switching between 4-
> > and 5-level paging.
> 
> This is the very wrong reason for tagging this commit stable.
> 
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: <stable@vger.kernel.org>	[4.14+]
> 
> Adding cc stable  requires a Fixes tag as well.
> 
> > +int l5_paging_required(void)
> > +{
> > +	/* Check i leaf 7 is supported. */
> 
> So you introduce the typo here and then you fix it in the next patch which
> is the actual bug fix as an completely unrelated hunk.
> 
> -- a/arch/x86/boot/compressed/pgtable_64.c
> +++ b/arch/x86/boot/compressed/pgtable_64.c
> @@ -2,7 +2,7 @@
>  
>  int l5_paging_required(void)
>  {
> -       /* Check i leaf 7 is supported. */
> +       /* Check if leaf 7 is supported. */
> 
> That's just careless and sloppy.
> 
> I fixed it up once more along with the lousy changelogs because this crap,
> which you not even thought about addressing it when shoving your 5-level
> support into 4.14 needs to be fixed.
> 
> I'm really tired of your sloppiness. You waste everyones time just by
> ignoring feedback and continuing to do what you think is enough. Works for
> me is _NOT_ enough for kernel development.

Sorry. I screwed it up.

I'll do my best to not waste your time again.

> I'm not even looking at the rest of the series unless someone else has the
> stomach to do so and sends a Reviewed-by.
> 
> Alternatively you can sit down and look at the changelogs and the code and
> figure out whether it matches what I told you over and over. Once you think
> it does, then please feel free to resend it, but be sure that I'm going to
> apply the most restrictive crap filter on anything which comes from you
> from now on.

Fair enough. I'll recheck everything in the morning and send them again.

Thanks,
  and sorry again for wasting your time.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
