Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 40ABE6B045F
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:55:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y16so1308331wmd.6
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:55:11 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id qq8si8475577wjc.143.2016.11.18.09.55.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 09:55:10 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id f82so52755113wmf.1
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:55:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1611181146330.26818@east.gentwo.org>
References: <1479376267-18486-1-git-send-email-mpe@ellerman.id.au> <alpine.DEB.2.20.1611181146330.26818@east.gentwo.org>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 18 Nov 2016 09:55:08 -0800
Message-ID: <CAGXu5jKC8XTP=gjCGQYEEwSQEAWM66E8HedaEqZR3F=QSm+aTg@mail.gmail.com>
Subject: Re: [PATCH v2] slab: Add POISON_POINTER_DELTA to ZERO_SIZE_PTR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Fri, Nov 18, 2016 at 9:47 AM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 17 Nov 2016, Michael Ellerman wrote:
>
>> Currently ZERO_OR_NULL_PTR() uses a trick of doing a single check that
>> x <= ZERO_SIZE_PTR, and ignoring the fact that it also matches 1-15.
>
> Well yes that was done so we do not add too many branches all over the
> kernel.....

There are actually very few callers of this macro. (Though it's
possible they're executed frequently.)

>> That no longer really works once we add the poison delta, so split it
>> into two checks. Assign x to a temporary to avoid evaluating it
>> twice (suggested by Kees Cook).
>
> And now you are doing just that.

In this case, what about the original < ZERO_SIZE_PTR check Michael
suggested? At least the one use in usercopy.c needs to be fixed, but
otherwise, it should be fine?

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
