Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7AC6B0005
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 14:43:43 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id z65-v6so19198905ywa.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 11:43:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c205-v6sor2960581ybb.113.2018.07.02.11.43.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 11:43:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5506a72f-99ac-b47c-4ace-86c43b17b5c5@redhat.com>
References: <1530101255-13988-1-git-send-email-crecklin@redhat.com>
 <CAGXu5jLDULvf-VBhUfBXtSNaSWpq8irgg56LT3nHDft5gZg5Lw@mail.gmail.com> <5506a72f-99ac-b47c-4ace-86c43b17b5c5@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 2 Jul 2018 11:43:40 -0700
Message-ID: <CAGXu5jL8XDYE+B=a_TBM2K8F-c3f4Jz6zcm3ggacbPNN2wCtpg@mail.gmail.com>
Subject: Re: [PATCH v3] add param that allows bootline control of hardened usercopy
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris von Recklinghausen <crecklin@redhat.com>
Cc: Laura Abbott <labbott@redhat.com>, Paolo Abeni <pabeni@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Sat, Jun 30, 2018 at 1:43 PM, Christoph von Recklinghausen
<crecklin@redhat.com> wrote:
> The last issue I'm chasing is build failures on ARCH=m68k. The error is
> atomic_read and friends needed by the jump label code not being found.
> The config has CONFIG_BROKEN_ON_SMP=y, so the jump label calls I added
> will only be made #ifndef CONFIG_BROKEN_ON_SMP. Do you think that's
> worth a mention in the blurb that's added to
> Documentation/admin-guide/kernel-parameters.txt?

Uhm, that's weird -- I think the configs on m68k need fixing then? I
don't want to have to sprinkle that ifdef in generic code.

How are other users of static keys and jump labels dealing with m68k weirdness?

-Kees

-- 
Kees Cook
Pixel Security
