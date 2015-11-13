Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 013186B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 04:01:30 -0500 (EST)
Received: by qkfo3 with SMTP id o3so40809335qkf.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 01:01:29 -0800 (PST)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id 92si15091368qks.80.2015.11.13.01.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 01:01:29 -0800 (PST)
Received: by qkas77 with SMTP id s77so4755977qka.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 01:01:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFx84N=o=RWJTy2Bjs-GNjKQuCZYyVWDTgOtRq3-qSO-yg@mail.gmail.com>
References: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20151110123429.GE19187@pd.tnic>
	<20151110135303.GA11246@node.shutemov.name>
	<20151110144648.GG19187@pd.tnic>
	<20151110150713.GA11956@node.shutemov.name>
	<20151110170447.GH19187@pd.tnic>
	<20151111095101.GA22512@pd.tnic>
	<20151112074854.GA5376@gmail.com>
	<20151112075758.GA20702@node.shutemov.name>
	<20151112080059.GA6835@gmail.com>
	<CA+55aFx84N=o=RWJTy2Bjs-GNjKQuCZYyVWDTgOtRq3-qSO-yg@mail.gmail.com>
Date: Fri, 13 Nov 2015 01:01:28 -0800
Message-ID: <CAA9_cmei11nOh8oO_kFyqupf=MSpMHN-OZxVCRajZs1zenu7QA@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
From: Dan Williams <dan.j.williams@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Anvin <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, elliott@hpe.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Toshi Kani <toshi.kani@hpe.com>

On Thu, Nov 12, 2015 at 11:29 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, Nov 12, 2015 at 12:00 AM, Ingo Molnar <mingo@kernel.org> wrote:
[..]
> I have this dim memory of us playing around with just making PAGE_SIZE
> (and thus PAGE_MASK) always be signed, but that it caused other
> problems. Signed types have downsides too.

FWIW, I ran into this recently with the pfn_t patch.  mips and powerpc
have PAGE_MASK as a signed int.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
