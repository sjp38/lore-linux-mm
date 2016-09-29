Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C71406B0253
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 12:08:37 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id p135so72787443itb.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 09:08:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j9si17135152ite.90.2016.09.29.09.08.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 09:08:10 -0700 (PDT)
Date: Thu, 29 Sep 2016 18:07:02 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5] powerpc: Do not make the entire heap executable
Message-ID: <20160929160702.GA30031@redhat.com>
References: <20160822185105.29600-1-dvlasenk@redhat.com> <87d1jo7qbw.fsf@concordia.ellerman.id.au> <CAGXu5jKzvF_vTdNQfcugcG6PqEeDjVxymYXFtsksLx6jN-Z4zg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jKzvF_vTdNQfcugcG6PqEeDjVxymYXFtsksLx6jN-Z4zg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Al Viro <viro@zeniv.linux.org.uk>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 09/28, Kees Cook wrote:
>
> This is where the flags are actually built from what's coming in
> through the newly created exported function vm_brk_flags() below. The
> only flag we're acting on is VM_EXEC (passed in from set_brk() above).
> I think do_brk_flags() should mask the valid flags, or we'll regret it
> in the future. I'd like to see something like:
>
>     /* Until we need other flags, refuse anything except VM_EXEC. */
>     if ((flags & (~VM_EXEC)) != 0)
>         return -EINVAL;
>     flags |= VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;

I tried to suggest this too. In particular it would be simply wrong
to accept VM_LOCKED in flags.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
