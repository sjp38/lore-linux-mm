Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5710E6B0467
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 13:19:40 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id o1so35456152ito.7
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 10:19:40 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id 188si2883411iti.48.2016.11.18.10.19.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 10:19:39 -0800 (PST)
Date: Fri, 18 Nov 2016 12:19:42 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] slab: Add POISON_POINTER_DELTA to ZERO_SIZE_PTR
In-Reply-To: <CAGXu5jKC8XTP=gjCGQYEEwSQEAWM66E8HedaEqZR3F=QSm+aTg@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1611181219250.27160@east.gentwo.org>
References: <1479376267-18486-1-git-send-email-mpe@ellerman.id.au> <alpine.DEB.2.20.1611181146330.26818@east.gentwo.org> <CAGXu5jKC8XTP=gjCGQYEEwSQEAWM66E8HedaEqZR3F=QSm+aTg@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>


On Fri, 18 Nov 2016, Kees Cook wrote:
> In this case, what about the original < ZERO_SIZE_PTR check Michael
> suggested? At least the one use in usercopy.c needs to be fixed, but
> otherwise, it should be fine?

Looks like it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
