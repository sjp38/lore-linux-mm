Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC1B6B0280
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 04:43:23 -0500 (EST)
Received: by mail-lf0-f45.google.com with SMTP id y184so209503684lfc.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 01:43:23 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id q7si38482732lbs.24.2015.12.29.01.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Dec 2015 01:43:21 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id y184so21641805lfc.0
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 01:43:21 -0800 (PST)
Date: Tue, 29 Dec 2015 12:43:18 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH RFC] mm: Rework virtual memory accounting
Message-ID: <20151229094318.GM2194@uranus>
References: <20151228211015.GL2194@uranus>
 <CA+55aFzxT02gGCAokDFich=kjsf1VtvL=i315Uk9p=HRrCAY5Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzxT02gGCAokDFich=kjsf1VtvL=i315Uk9p=HRrCAY5Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Andrew Morton <akpm@linuxfoundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, Dec 28, 2015 at 02:22:23PM -0800, Linus Torvalds wrote:
> On Mon, Dec 28, 2015 at 1:10 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> > Really sorry for delays. Konstantin, I slightly updated the
> > changelog (to point where problem came from). Linus are you
> > fine with accounting not only anonymous memory in VmData?
> 
> The patch looks ok to me. I guess if somebody relies on old behavior
> we may have to tweak it a bit, but on the whole this looks sane and
> I'd be happy to merge it in the 4.5 merge window (and maybe even have
> it marked for stable if it works out)

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
