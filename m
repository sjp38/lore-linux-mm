Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id EEC816B0314
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 18:45:46 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id h4so184224185oib.5
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 15:45:46 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 32si3945509otw.28.2017.06.06.15.45.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 15:45:46 -0700 (PDT)
Received: from mail-ua0-f180.google.com (mail-ua0-f180.google.com [209.85.217.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5F9B423A12
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 22:45:45 +0000 (UTC)
Received: by mail-ua0-f180.google.com with SMTP id q15so15701199uaa.2
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 15:45:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <E1A42E76-A583-490F-9667-37A5CB4005E2@gmail.com>
References: <cover.1496701658.git.luto@kernel.org> <fa028af2168f71ab55522eb19b320c167ba4678d.1496701658.git.luto@kernel.org>
 <E1A42E76-A583-490F-9667-37A5CB4005E2@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 6 Jun 2017 15:45:23 -0700
Message-ID: <CALCETrXUcjE6_BcpFPB10Poa3kiXP_8RoMP8e=wj3HvgE0H7xA@mail.gmail.com>
Subject: Re: [RFC 04/11] x86/mm: Track the TLB's tlb_gen and update the
 flushing algorithm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

On Mon, Jun 5, 2017 at 10:03 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
> Maybe it=E2=80=99s me, but I find it rather hard to figure out whether
> flush_tlb_func_common() is safe, since it can be re-entered - if a local =
TLB
> flush is performed, and during this local flush a remote shootdown IPI is
> received.
>
> Did I miss irq being disabled during the local flush?
>

Whoops!  In my head, it was disabled.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
