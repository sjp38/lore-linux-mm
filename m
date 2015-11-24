Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A1EDF6B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 15:14:54 -0500 (EST)
Received: by wmvv187 with SMTP id v187so227115000wmv.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 12:14:54 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id s202si442974wmb.21.2015.11.24.12.14.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 12:14:53 -0800 (PST)
Received: by wmvv187 with SMTP id v187so227113062wmv.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 12:14:51 -0800 (PST)
Date: Tue, 24 Nov 2015 22:14:49 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151124201448.GA8954@node.shutemov.name>
References: <20151110150713.GA11956@node.shutemov.name>
 <20151110170447.GH19187@pd.tnic>
 <20151111095101.GA22512@pd.tnic>
 <20151112074854.GA5376@gmail.com>
 <20151112075758.GA20702@node.shutemov.name>
 <20151112080059.GA6835@gmail.com>
 <20151112084616.EABFE19B@black.fi.intel.com>
 <20151112085418.GA18963@gmail.com>
 <20151112090018.GA22481@node.shutemov.name>
 <56547B4F.6030902@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56547B4F.6030902@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Borislav Petkov <bp@alien8.de>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, Toshi Kani <toshi.kani@hpe.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Nov 24, 2015 at 09:59:27AM -0500, Boris Ostrovsky wrote:
> On 11/12/2015 04:00 AM, Kirill A. Shutemov wrote:
> >On Thu, Nov 12, 2015 at 09:54:18AM +0100, Ingo Molnar wrote:
> >>* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> >>
> >>>diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
> >>>index c5b7fb2774d0..cc071c6f7d4d 100644
> >>>--- a/arch/x86/include/asm/page_types.h
> >>>+++ b/arch/x86/include/asm/page_types.h
> 
> 
> Kirill, where are we with this patch?

I haven't seen any actionable objections to the updated patch.
Not sure why it's not applied.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
