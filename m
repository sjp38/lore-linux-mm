Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E85D26B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 15:10:48 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j194so11966605oib.15
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 12:10:48 -0700 (PDT)
Received: from mail-it0-x22c.google.com (mail-it0-x22c.google.com. [2607:f8b0:4001:c0b::22c])
        by mx.google.com with ESMTPS id i20si5088425oib.80.2017.08.14.12.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 12:10:48 -0700 (PDT)
Received: by mail-it0-x22c.google.com with SMTP id m34so204301iti.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 12:10:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170809200755.11234-11-tycho@docker.com>
References: <20170809200755.11234-1-tycho@docker.com> <20170809200755.11234-11-tycho@docker.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 14 Aug 2017 12:10:47 -0700
Message-ID: <CAGXu5jLp11wqM04L5bWbmSVZBTOYnuGNjsjTitzUOFJm=pn9Fg@mail.gmail.com>
Subject: Re: [PATCH v5 10/10] lkdtm: Add test for XPFO
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On Wed, Aug 9, 2017 at 1:07 PM, Tycho Andersen <tycho@docker.com> wrote:
> From: Juerg Haefliger <juerg.haefliger@hpe.com>
>
> This test simply reads from userspace memory via the kernel's linear
> map.
>
> hugepages is only supported on x86 right now, hence the ifdef.

I'd prefer that the #ifdef is handled in the .c file. The result is
that all architectures will have the XPFO_READ_USER_HUGE test, but it
can just fail when not available. This means no changes are needed for
lkdtm in the future and the test provides an actual test of hugepages
coverage.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
