Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id EA0E9828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 18:33:17 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id py5so101292005obc.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:33:17 -0800 (PST)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id j186si4168147oib.4.2016.01.13.15.33.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 15:33:17 -0800 (PST)
Received: by mail-oi0-x22f.google.com with SMTP id w75so73247120oie.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:33:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160111105105.GB29448@gmail.com>
References: <cover.1452294700.git.luto@kernel.org> <a75dbc8fb47148e7f7f3b171c033a5a11d83e690.1452294700.git.luto@kernel.org>
 <CA+55aFxChuKFYyUtG6a+zn82JFB=9XaM6mH9V+kdYa9iEDKUzQ@mail.gmail.com>
 <CALCETrX9yheo2VK=jhqvikumXrPfdHmNCLgkjugLQnLWSawv9A@mail.gmail.com>
 <CA+55aFy=mNDvedPwSF01F-QHEsFdGu63qiGPvmp_Cnhb0CvG+A@mail.gmail.com> <20160111105105.GB29448@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 13 Jan 2016 15:32:56 -0800
Message-ID: <CALCETrVMBrthXRgsG3M39P3ud+H=PHi7J=qniuVWHAgXejzCHA@mail.gmail.com>
Subject: Re: [RFC 09/13] x86/mm: Disable interrupts when flushing the TLB
 using CR3
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Brian Gerst <brgerst@gmail.com>

On Mon, Jan 11, 2016 at 2:51 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
>> >> Or is there some reason you wanted the odd flags version? If so, that
>> >> should be documented.
>> >
>> > What do you mean "odd"?
>>
>> It's odd because it makes no sense for non-pcid (christ, I wish Intel had just
>> called it "asid" instead, "pcid" always makes me react to "pci"), and I think it
>> would make more sense to pair up the pcid case with the invpcid rather than have
>> those preemption rules here.
>
> The naming is really painful, so a trivial suggestion: could we just name all the
> Linux side bits 'asid' or 'ctx_id' (even in x86 arch code) and only use 'PCID'
> nomenclature in the very lowest level code?

I'd be okay with "pctx_id" or "pctxid" for this, I think.  I'd like to
at least make it somewhat obvious how it maps back to hardware.

FWIW, I'd guess that Intel deviated from convention because their
actual address space id is (vpid, pcid), and calling it (vpid, asid)
might have been slightly confusing.  Or not.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
