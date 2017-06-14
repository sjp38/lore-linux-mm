Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 82E276B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 00:52:27 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id i42so64841743otb.0
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 21:52:27 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u30si1157453otd.142.2017.06.13.21.52.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 21:52:25 -0700 (PDT)
Received: from mail-ua0-f173.google.com (mail-ua0-f173.google.com [209.85.217.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E524B239B5
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 04:52:24 +0000 (UTC)
Received: by mail-ua0-f173.google.com with SMTP id m31so87834447uam.1
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 21:52:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87wp8pol4u.fsf@firstfloor.org>
References: <cover.1496701658.git.luto@kernel.org> <d4eafd524ee51d003d7f7302d5e4e44dc4919e08.1496701658.git.luto@kernel.org>
 <87wp8pol4u.fsf@firstfloor.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 13 Jun 2017 21:52:03 -0700
Message-ID: <CALCETrV-Wkqt89fJmjgK_BAdmzvXG8Vr1aTXDSnLRPO1NhwYYA@mail.gmail.com>
Subject: Re: [RFC 08/11] x86/mm: Add nopcid to turn off PCID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>

On Mon, Jun 5, 2017 at 8:22 PM, Andi Kleen <andi@firstfloor.org> wrote:
> Andy Lutomirski <luto@kernel.org> writes:
>
>> The parameter is only present on x86_64 systems to save a few bytes,
>> as PCID is always disabled on x86_32.
>
> Seems redundant with clearcpuid.
>

It is.  OTOH, there are lots of noxyz options, and they're easier to
type and to remember.  Borislav?  Sometime I wonder whether we should
autogenerate noxyz options from the capflags table.

> -Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
