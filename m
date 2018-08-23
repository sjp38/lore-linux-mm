Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFEC26B27DE
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 23:35:29 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id n17-v6so3275494ioa.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 20:35:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f70-v6sor796691ita.46.2018.08.22.20.35.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 20:35:28 -0700 (PDT)
MIME-Version: 1.0
References: <20180822153012.173508681@infradead.org> <20180822154046.772017055@infradead.org>
 <20180823133103.30d6a16b@roar.ozlabs.ibm.com>
In-Reply-To: <20180823133103.30d6a16b@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Aug 2018 20:35:16 -0700
Message-ID: <CA+55aFyY4fG8Hhds4ykSm5vUMdxbLdB7mYmC2pOPk8UKBXtpjA@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm/tlb: Remove tlb_remove_table() non-concurrent condition
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Aug 22, 2018 at 8:31 PM Nicholas Piggin <npiggin@gmail.com> wrote:
>
>
> So that leaves speculative operations. I don't see where the problem is
> with those either -- this shortcut needs to ensure there are no other
> *non speculative* operations. mm_users is correct for that.

No. Because mm_users doesn't contain any lazy tlb users.

And yes, those lazy tlbs are all kernel threads, but they can still
speculatively load user addresses.

           Linus
