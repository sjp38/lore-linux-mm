Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 56538828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 05:51:09 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id l65so205686806wmf.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 02:51:09 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id p13si22023736wmb.82.2016.01.11.02.51.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 02:51:08 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id l65so25658006wmf.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 02:51:08 -0800 (PST)
Date: Mon, 11 Jan 2016 11:51:05 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC 09/13] x86/mm: Disable interrupts when flushing the TLB
 using CR3
Message-ID: <20160111105105.GB29448@gmail.com>
References: <cover.1452294700.git.luto@kernel.org>
 <a75dbc8fb47148e7f7f3b171c033a5a11d83e690.1452294700.git.luto@kernel.org>
 <CA+55aFxChuKFYyUtG6a+zn82JFB=9XaM6mH9V+kdYa9iEDKUzQ@mail.gmail.com>
 <CALCETrX9yheo2VK=jhqvikumXrPfdHmNCLgkjugLQnLWSawv9A@mail.gmail.com>
 <CA+55aFy=mNDvedPwSF01F-QHEsFdGu63qiGPvmp_Cnhb0CvG+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFy=mNDvedPwSF01F-QHEsFdGu63qiGPvmp_Cnhb0CvG+A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Brian Gerst <brgerst@gmail.com>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> >> Or is there some reason you wanted the odd flags version? If so, that
> >> should be documented.
> >
> > What do you mean "odd"?
> 
> It's odd because it makes no sense for non-pcid (christ, I wish Intel had just 
> called it "asid" instead, "pcid" always makes me react to "pci"), and I think it 
> would make more sense to pair up the pcid case with the invpcid rather than have 
> those preemption rules here.

The naming is really painful, so a trivial suggestion: could we just name all the 
Linux side bits 'asid' or 'ctx_id' (even in x86 arch code) and only use 'PCID' 
nomenclature in the very lowest level code?

I.e. rename pcid_live_cpus et al and most functions to the asid or ctx_id or asid 
naming scheme or so. That would hide most of the naming ugliness.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
