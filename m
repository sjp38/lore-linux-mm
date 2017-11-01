Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 736F46B0261
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 04:02:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p87so1581802pfj.21
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 01:02:07 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y6si3882783pgp.587.2017.11.01.01.02.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 01:02:06 -0700 (PDT)
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 320BE2192C
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 08:02:06 +0000 (UTC)
Received: by mail-io0-f174.google.com with SMTP id d66so3454132ioe.5
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 01:02:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031223154.67F15B2A@viggo.jf.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223154.67F15B2A@viggo.jf.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 1 Nov 2017 01:01:45 -0700
Message-ID: <CALCETrW06XjaWYD1O_HPXPDrHS96FZz9=OkPCQ3vsKrAxnr8+A@mail.gmail.com>
Subject: Re: [PATCH 04/23] x86, tlb: make CR4-based TLB flushes more robust
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Tue, Oct 31, 2017 at 3:31 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> Our CR4-based TLB flush currently requries global pages to be
> supported *and* enabled.  But, we really only need for them to be
> supported.  Make the code more robust by alllowing X86_CR4_PGE to
> clear as well as set.
>
> This change was suggested by Kirill Shutemov.

I may have missed something, but why would be ever have CR4.PGE off?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
