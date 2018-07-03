Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6DEA46B0008
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 04:04:53 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id v17-v6so329122ual.10
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 01:04:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v127-v6sor193483vkg.288.2018.07.03.01.04.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 01:04:52 -0700 (PDT)
MIME-Version: 1.0
References: <1530101255-13988-1-git-send-email-crecklin@redhat.com>
 <CAGXu5jLDULvf-VBhUfBXtSNaSWpq8irgg56LT3nHDft5gZg5Lw@mail.gmail.com>
 <5506a72f-99ac-b47c-4ace-86c43b17b5c5@redhat.com> <CAGXu5jL8XDYE+B=a_TBM2K8F-c3f4Jz6zcm3ggacbPNN2wCtpg@mail.gmail.com>
In-Reply-To: <CAGXu5jL8XDYE+B=a_TBM2K8F-c3f4Jz6zcm3ggacbPNN2wCtpg@mail.gmail.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 3 Jul 2018 10:04:40 +0200
Message-ID: <CAMuHMdU89jEp4Oi6RK887P-LxCFNVPMnOpvvC6BEDHWDjNATAw@mail.gmail.com>
Subject: Re: [PATCH v3] add param that allows bootline control of hardened usercopy
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: crecklin@redhat.com, Laura Abbott <labbott@redhat.com>, pabeni@redhat.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com, Josh Poimboeuf <jpoimboe@redhat.com>, Peter Zijlstra <peterz@infradead.org>

Hi Kees,

On Mon, Jul 2, 2018 at 8:44 PM Kees Cook <keescook@chromium.org> wrote:
> On Sat, Jun 30, 2018 at 1:43 PM, Christoph von Recklinghausen
> <crecklin@redhat.com> wrote:
> > The last issue I'm chasing is build failures on ARCH=m68k. The error is
> > atomic_read and friends needed by the jump label code not being found.
> > The config has CONFIG_BROKEN_ON_SMP=y, so the jump label calls I added
> > will only be made #ifndef CONFIG_BROKEN_ON_SMP. Do you think that's
> > worth a mention in the blurb that's added to
> > Documentation/admin-guide/kernel-parameters.txt?
>
> Uhm, that's weird -- I think the configs on m68k need fixing then? I
> don't want to have to sprinkle that ifdef in generic code.

config BROKEN_ON_SMP
        bool
        depends on BROKEN || !SMP
        default y

So BROKEN_ON_SMP=y if SMP=n, i.e. not an issue?

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
