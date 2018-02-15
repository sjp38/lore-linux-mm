Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 534206B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 12:47:12 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id v5so890908iog.10
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 09:47:12 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z196sor3148346itb.114.2018.02.15.09.47.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Feb 2018 09:47:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180215132053.6C9B48C8@viggo.jf.intel.com>
References: <20180215132053.6C9B48C8@viggo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 15 Feb 2018 09:47:10 -0800
Message-ID: <CA+55aFy8k_zSJ_ASyzkA9C-jLV4mZsHpv1sOxJ9qpvfS_P6eMg@mail.gmail.com>
Subject: Re: [PATCH 0/3] Use global pages with PTI
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>

On Thu, Feb 15, 2018 at 5:20 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> During the switch over to PTI, we seem to have lost our ability to have
> GLOBAL mappings.

Oops. Odd, I have this distinct memory of somebody even _testing_ the
global bit performance when I pointed out that we shouldn't just make
the bit go away entirely.

[ goes back and looks at archives ]

Oh, that was in fact you who did that performance test.

Heh. Anyway, back then you claimed a noticeable improvement on that
will-it-scale test (although a bigger one when pcid wasn't available),
so yes, if we lost the "global pages for the shared user/kernel
mapping" bit we should definitely get this fixed.

Did you perhaps re-run any benchmark numbers just to verify? Because
it's always good to back up patches that should improve performance
with actual numbers..

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
