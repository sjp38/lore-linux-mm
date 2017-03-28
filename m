Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 589F76B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 17:15:11 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l43so55490333wre.4
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 14:15:11 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id b127si4642870wmc.21.2017.03.28.14.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 14:15:10 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id u1so24725107wra.3
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 14:15:09 -0700 (PDT)
Date: Wed, 29 Mar 2017 00:15:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 6/8] x86/dump_pagetables: Add support 5-level paging
Message-ID: <20170328211507.ungejuigkewn6prl@node.shutemov.name>
References: <20170328093946.GA30567@gmail.com>
 <20170328104806.41711-1-kirill.shutemov@linux.intel.com>
 <20170328185522.5akqgfh4niqi3ptf@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328185522.5akqgfh4niqi3ptf@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 28, 2017 at 08:55:22PM +0200, Borislav Petkov wrote:
> On Tue, Mar 28, 2017 at 01:48:06PM +0300, Kirill A. Shutemov wrote:
> > Simple extension to support one more page table level.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/mm/dump_pagetables.c | 59 +++++++++++++++++++++++++++++++++----------
> >  1 file changed, 45 insertions(+), 14 deletions(-)
> 
> Hmm, so without this I get the splat below.

On current tip/master?

> Can we do something about this bisection breakage? I mean, this is the
> second explosion caused by 5level paging I trigger. Maybe we should
> merge the whole thing into a single big patch when everything is applied
> and tested, more or less, so that bisection is fine.
> 
> Or someone might have a better idea...

I'm not sure that collapsing history in one commit to fix bisectability is
any better than having broken bisectability.

I'll try to look more into this issue tomorrow.

Sorry for this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
