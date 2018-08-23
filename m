Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 40E0B6B27E9
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 23:44:18 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id m207-v6so4063781itg.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 20:44:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m1-v6sor1382230jab.0.2018.08.22.20.44.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 20:44:17 -0700 (PDT)
MIME-Version: 1.0
References: <20180822153012.173508681@infradead.org> <20180822154046.772017055@infradead.org>
 <20180823133103.30d6a16b@roar.ozlabs.ibm.com> <CA+55aFyY4fG8Hhds4ykSm5vUMdxbLdB7mYmC2pOPk8UKBXtpjA@mail.gmail.com>
In-Reply-To: <CA+55aFyY4fG8Hhds4ykSm5vUMdxbLdB7mYmC2pOPk8UKBXtpjA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Aug 2018 20:44:05 -0700
Message-ID: <CA+55aFwMu2cN44WL7hK-xZmHUcSiifYkADTzFnQBO1jmJpZhmg@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm/tlb: Remove tlb_remove_table() non-concurrent condition
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Aug 22, 2018 at 8:35 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> No. Because mm_users doesn't contain any lazy tlb users.

.. or, as it turns out, the use_mm() case either, which can do
gup_fast(). Oh well.

            Linus
