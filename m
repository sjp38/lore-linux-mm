Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F46D6B0009
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 13:52:36 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r19so1660443iod.7
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 10:52:36 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 191sor412069ioe.271.2018.04.02.10.52.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 10:52:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180402172701.5D4CA7DD@viggo.jf.intel.com>
References: <20180402172700.65CAE838@viggo.jf.intel.com> <20180402172701.5D4CA7DD@viggo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 2 Apr 2018 10:52:34 -0700
Message-ID: <CA+55aFw7mLJrr+VqvEY-T3KqR2-xaYSoyU2Jg7VY1Sb1cu1L-w@mail.gmail.com>
Subject: Re: [PATCH 01/11] x86/mm: factor out pageattr _PAGE_GLOBAL setting
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On Mon, Apr 2, 2018 at 10:27 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> Aside: _PAGE_GLOBAL is ignored when CR4.PGE=1, so why do we
> even go to the trouble of filtering it anywhere?

I'm assuming this is a typo, and you mean "when CR4.PGE=0".

The question you raise may be valid, but within the particular context
of *this* patch it is not.

In the context of this particular patch, the issue is that we use
_PAGE_GLOBAL as _PAGE_BIT_PROTNONE when the present bit isn't set.

       Linus
