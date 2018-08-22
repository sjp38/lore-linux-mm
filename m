Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C15E06B267C
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 17:37:17 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n17-v6so2650463ioa.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 14:37:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w66-v6sor976840itd.125.2018.08.22.14.37.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 14:37:17 -0700 (PDT)
MIME-Version: 1.0
References: <20180822153012.173508681@infradead.org> <20180822154046.717610121@infradead.org>
In-Reply-To: <20180822154046.717610121@infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Aug 2018 14:37:05 -0700
Message-ID: <CA+55aFw6bBFnV__JZnzh0ZCSTma5J2ijH8BnMtfK55dnjVp=dw@mail.gmail.com>
Subject: Re: [PATCH 1/4] x86/mm/tlb: Revert the recent lazy TLB patches
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, Aug 22, 2018 at 8:46 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> Revert [..] in order to simplify the TLB invalidate fixes for x86. We'll try again later.

Rik, I assume I should take your earlier "yeah, I can try later" as an
ack for this?

I'll wait a bit more in the hopes of getting reviews/acks, but I'm
basically chomping at the bit to just apply this series and have this
issue behind us.

             Linus
