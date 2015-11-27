Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 101916B0255
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 05:15:01 -0500 (EST)
Received: by wmec201 with SMTP id c201so52191671wme.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 02:15:00 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id yp10si47274025wjc.138.2015.11.27.02.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 02:14:59 -0800 (PST)
Received: by wmuu63 with SMTP id u63so49579475wmu.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 02:14:59 -0800 (PST)
Date: Fri, 27 Nov 2015 11:14:56 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151127101456.GA650@gmail.com>
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
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124201448.GA8954@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Borislav Petkov <bp@alien8.de>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, Toshi Kani <toshi.kani@hpe.com>, Linus Torvalds <torvalds@linux-foundation.org>


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Tue, Nov 24, 2015 at 09:59:27AM -0500, Boris Ostrovsky wrote:
> > On 11/12/2015 04:00 AM, Kirill A. Shutemov wrote:
> > >On Thu, Nov 12, 2015 at 09:54:18AM +0100, Ingo Molnar wrote:
> > >>* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> > >>
> > >>>diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
> > >>>index c5b7fb2774d0..cc071c6f7d4d 100644
> > >>>--- a/arch/x86/include/asm/page_types.h
> > >>>+++ b/arch/x86/include/asm/page_types.h
> > 
> > 
> > Kirill, where are we with this patch?
> 
> I haven't seen any actionable objections to the updated patch.
> Not sure why it's not applied.

So I think that happened because you did not change the subject line to a new, 
fresh one, that indicates it's a patch intended to be applied.

Patches sent inside existing discussions, under the same subject, tend to be 
test-only or discussion-only patches, to be submitted for real, in 95% of the 
cases.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
