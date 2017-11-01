Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4802E6B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:24:40 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z11so3182068pfk.23
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:24:40 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b5si1884925pgr.120.2017.11.01.14.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 14:24:39 -0700 (PDT)
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DFA6D21959
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 21:24:38 +0000 (UTC)
Received: by mail-io0-f182.google.com with SMTP id 101so9251939ioj.3
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:24:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711012206050.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711012206050.1942@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 1 Nov 2017 14:24:17 -0700
Message-ID: <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Wed, Nov 1, 2017 at 2:11 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Tue, 31 Oct 2017, Dave Hansen wrote:
>
>>
>> init_mm is for kernel-exclusive use.  If someone is allocating page
>> tables in it, do not set _PAGE_USER on them.  This ensures that
>> we do *not* set NX on these page tables in the KAISER code.
>
> This changelog is confusing at best.
>
> Why is this a kaiser issue? Nothing should ever create _PAGE_USER entries
> in init_mm, right?

The vsyscall page is _PAGE_USER and lives in init_mm via the fixmap.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
