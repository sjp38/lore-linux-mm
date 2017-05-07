Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B825D6B03B3
	for <linux-mm@kvack.org>; Sun,  7 May 2017 12:05:32 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 67so46730673itx.11
        for <linux-mm@kvack.org>; Sun, 07 May 2017 09:05:32 -0700 (PDT)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id l11si10094335ith.108.2017.05.07.09.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 09:05:32 -0700 (PDT)
Received: by mail-io0-x232.google.com with SMTP id p24so38342578ioi.0
        for <linux-mm@kvack.org>; Sun, 07 May 2017 09:05:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 7 May 2017 09:05:31 -0700
Message-ID: <CA+55aFy3KVr9o+++d56=6iYLdp3KcqzcE0Svs-ZVqBUPTmc9Vw@mail.gmail.com>
Subject: Re: [RFC 00/10] x86 TLB flush cleanups, moving toward PCID support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, May 7, 2017 at 5:38 AM, Andy Lutomirski <luto@kernel.org> wrote:
>
> This series goes a long way toward cleaning up the mess.  With all the
> patches applied, there is a single function that contains the meat of
> the code to flush the TLB on a given CPU, and all the tlb flushing
> APIs call it for both local and remote CPUs.

Looks fine to me. I'm always a bit nervous about TLB changes like this
just because any potential bugs tend to be really really hard to see
and catch, but I don't see anything wrong in the series.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
