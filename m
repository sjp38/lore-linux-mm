Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 684516B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 22:11:43 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id q15-v6so194913itb.7
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 19:11:43 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y79sor1787941ioy.9.2018.04.03.19.11.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 19:11:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180404010946.6186729B@viggo.jf.intel.com>
References: <20180404010946.6186729B@viggo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 3 Apr 2018 19:11:41 -0700
Message-ID: <CA+55aFxYunj-s2N60Q2Y63TsrhJKwqLa=-GJPMb6--RA_ud6Fw@mail.gmail.com>
Subject: Re: [PATCH 00/11] [v4] Use global pages with PTI
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On Tue, Apr 3, 2018 at 6:09 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
> Changes from v3:
>  * Fix whitespace issue noticed by willy
>  * Clarify comments about X86_FEATURE_PGE checks
>  * Clarify commit message around the necessity of _PAGE_GLOBAL
>    filtering when CR4.PGE=0 or PGE is unsupported.

I couldn't see anything odd in this, but I only read the explanations
and the patches, and the devil is in the details.

But it all looks sane to me, and the added comments all seemed like
good ideas. Plus the performance numbers certainly speak for
themselves, even if the big changes are from that Atom microserver
that I probably personally wouldn't want to use anyway ;).

So Ack from me, maybe a weak review.

               Linus
