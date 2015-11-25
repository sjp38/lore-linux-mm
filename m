Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9493C6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:27:43 -0500 (EST)
Received: by wmec201 with SMTP id c201so249222096wme.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 02:27:43 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id an2si33572715wjc.209.2015.11.25.02.27.42
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 02:27:42 -0800 (PST)
Date: Wed, 25 Nov 2015 11:27:38 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151125102738.GD29499@pd.tnic>
References: <20151110170447.GH19187@pd.tnic>
 <20151111095101.GA22512@pd.tnic>
 <20151112074854.GA5376@gmail.com>
 <20151112075758.GA20702@node.shutemov.name>
 <20151112080059.GA6835@gmail.com>
 <20151112084616.EABFE19B@black.fi.intel.com>
 <20151112085418.GA18963@gmail.com>
 <20151112090018.GA22481@node.shutemov.name>
 <56547B4F.6030902@oracle.com>
 <20151124201448.GA8954@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20151124201448.GA8954@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, Toshi Kani <toshi.kani@hpe.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Nov 24, 2015 at 10:14:49PM +0200, Kirill A. Shutemov wrote:
> I haven't seen any actionable objections to the updated patch.
> Not sure why it's not applied.

It is now.

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
