Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6DB6B0033
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 15:44:58 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id v2so9739002pfa.10
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:44:58 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n8si5399553pll.619.2017.11.20.12.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 12:44:57 -0800 (PST)
Received: from mail-it0-f52.google.com (mail-it0-f52.google.com [209.85.214.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id ADDE221986
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 20:44:56 +0000 (UTC)
Received: by mail-it0-f52.google.com with SMTP id x13so5117684iti.4
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:44:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171110193138.1185728D@viggo.jf.intel.com>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193138.1185728D@viggo.jf.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 20 Nov 2017 12:44:35 -0800
Message-ID: <CALCETrUgi-q1S82Btjjhk7tpPim+M1QzicGu7a6hAva-tbBVzQ@mail.gmail.com>
Subject: Re: [PATCH 17/30] x86, kaiser: map debug IDT tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Fri, Nov 10, 2017 at 11:31 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> The IDT is another structure which the CPU references via a
> virtual address.  It also obviously needs these to handle an
> interrupt in userspace, so these need to be mapped into the user
> copy of the page tables.

Why would the debug IDT ever be used in user mode?  IIRC it's a total
turd related to avoiding crap nesting inside NMI.  Or am I wrong?

If it *is* used in user mode, then we have a bug and it should be in
the IDT to avoid address leaks just like the normal IDT.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
