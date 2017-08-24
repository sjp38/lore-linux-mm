Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 10A56440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 14:43:24 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w14so412232wrc.5
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 11:43:24 -0700 (PDT)
Received: from mail-wr0-x229.google.com (mail-wr0-x229.google.com. [2a00:1450:400c:c0c::229])
        by mx.google.com with ESMTPS id h49si4958511edh.158.2017.08.24.11.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 11:43:16 -0700 (PDT)
Received: by mail-wr0-x229.google.com with SMTP id p14so920683wrg.3
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 11:43:16 -0700 (PDT)
Date: Thu, 24 Aug 2017 20:43:13 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86/mm: fix use-after-free of ldt_struct
Message-ID: <20170824184313.ibjiwbxsxdhm5o5b@gmail.com>
References: <20170824175029.76040-1-ebiggers3@gmail.com>
 <43bcad51-b210-c1fa-c729-471fe008ba61@linux.intel.com>
 <CA+55aFw6zfaM=LubJnsERYVtaSdvNtGfFNRxeHvC=hahrh6wVA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw6zfaM=LubJnsERYVtaSdvNtGfFNRxeHvC=hahrh6wVA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Eric Biggers <ebiggers3@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Christoph Hellwig <hch@lst.de>, Denys Vlasenko <dvlasenk@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, stable <stable@vger.kernel.org>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Ingo,
> 
>  I'm assuming I get this through the -tip tree, which is where the
> original commit 39a0526fb3f7 ("x86/mm: Factor out LDT init from
> context init") came from.

Yes, will do!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
