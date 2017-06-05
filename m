Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9836B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 18:40:31 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i206so178511155ita.10
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:40:31 -0700 (PDT)
Received: from mail-it0-x22f.google.com (mail-it0-x22f.google.com. [2607:f8b0:4001:c0b::22f])
        by mx.google.com with ESMTPS id w3si12650717ita.40.2017.06.05.15.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 15:40:30 -0700 (PDT)
Received: by mail-it0-x22f.google.com with SMTP id m47so19163825iti.1
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:40:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a5eb3dead15bcb36732bb5b655ef4ebe23cf4aa3.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org> <a5eb3dead15bcb36732bb5b655ef4ebe23cf4aa3.1496701658.git.luto@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 5 Jun 2017 15:40:29 -0700
Message-ID: <CA+55aFwrCep+F8zV-fK5ufiDRX+N9yTcHMsyR-JhvFeoD-1LYg@mail.gmail.com>
Subject: Re: [RFC 01/11] x86/ldt: Simplify LDT switching logic
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>

On Mon, Jun 5, 2017 at 3:36 PM, Andy Lutomirski <luto@kernel.org> wrote:
> We used to switch the LDT if the prev and next mms' LDTs didn't
> match.

I think the "LDT didn't match" was really just a simpler and more
efficient way to say "they weren't both NULL".

I think you actually broke that optimization, and it now does *two*
tests instead of just one.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
