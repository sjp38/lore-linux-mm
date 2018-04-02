Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C376B6B0009
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 13:56:28 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r141so3320955ior.15
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 10:56:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g186-v6sor533137itg.76.2018.04.02.10.56.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 10:56:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180402172713.B7D6F0C0@viggo.jf.intel.com>
References: <20180402172700.65CAE838@viggo.jf.intel.com> <20180402172713.B7D6F0C0@viggo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 2 Apr 2018 10:56:26 -0700
Message-ID: <CA+55aFx5GCahkr_-Y0qF5S=USCXhNcvWZ6gr_TxpvUVAh46STA@mail.gmail.com>
Subject: Re: [PATCH 09/11] x86/pti: enable global pages for shared areas
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On Mon, Apr 2, 2018 at 10:27 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> +       /*
> +        * The cpu_entry_area is shared between the user and kernel
> +        * page tables.  All of its ptes can safely be global.
> +        */
> +       if (boot_cpu_has(X86_FEATURE_PGE))
> +               pte = pte_set_flags(pte, _PAGE_GLOBAL);

So this is where the quesion of "why is this conditional" is valid.

We could set _PAGE_GLOBAL unconditionally, not bothering with testing
X86_FEATURE_PGE.

                Linus
