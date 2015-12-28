Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 597C76B027F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 17:22:24 -0500 (EST)
Received: by mail-io0-f172.google.com with SMTP id 77so5196732ioc.2
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 14:22:24 -0800 (PST)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id e91si39384125ioi.138.2015.12.28.14.22.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Dec 2015 14:22:23 -0800 (PST)
Received: by mail-io0-x243.google.com with SMTP id o67so29007356iof.2
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 14:22:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151228211015.GL2194@uranus>
References: <20151228211015.GL2194@uranus>
Date: Mon, 28 Dec 2015 14:22:23 -0800
Message-ID: <CA+55aFzxT02gGCAokDFich=kjsf1VtvL=i315Uk9p=HRrCAY5Q@mail.gmail.com>
Subject: Re: [PATCH RFC] mm: Rework virtual memory accounting
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Andrew Morton <akpm@linuxfoundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, Dec 28, 2015 at 1:10 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> Really sorry for delays. Konstantin, I slightly updated the
> changelog (to point where problem came from). Linus are you
> fine with accounting not only anonymous memory in VmData?

The patch looks ok to me. I guess if somebody relies on old behavior
we may have to tweak it a bit, but on the whole this looks sane and
I'd be happy to merge it in the 4.5 merge window (and maybe even have
it marked for stable if it works out)

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
