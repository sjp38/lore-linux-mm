Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7576B002A
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:13:41 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q2so5284694pgn.22
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:13:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w10si5550060pgv.486.2018.03.16.15.13.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 15:13:39 -0700 (PDT)
Date: Fri, 16 Mar 2018 15:13:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3] ZBOOT: fix stack protector in compressed boot phase
Message-Id: <20180316151337.f277e3a734326672d41cec61@linux-foundation.org>
In-Reply-To: <1521186916-13745-1-git-send-email-chenhc@lemote.com>
References: <1521186916-13745-1-git-send-email-chenhc@lemote.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huacai Chen <chenhc@lemote.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, James Hogan <james.hogan@mips.com>, linux-mips@linux-mips.org, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, linux-sh@vger.kernel.org, stable@vger.kernel.org

On Fri, 16 Mar 2018 15:55:16 +0800 Huacai Chen <chenhc@lemote.com> wrote:

> Call __stack_chk_guard_setup() in decompress_kernel() is too late that
> stack checking always fails for decompress_kernel() itself. So remove
> __stack_chk_guard_setup() and initialize __stack_chk_guard before we
> call decompress_kernel().
> 
> Original code comes from ARM but also used for MIPS and SH, so fix them
> together. If without this fix, compressed booting of these archs will
> fail because stack checking is enabled by default (>=4.16).
> 
> ...
>
>  arch/arm/boot/compressed/head.S        | 4 ++++
>  arch/arm/boot/compressed/misc.c        | 7 -------
>  arch/mips/boot/compressed/decompress.c | 7 -------
>  arch/mips/boot/compressed/head.S       | 4 ++++
>  arch/sh/boot/compressed/head_32.S      | 8 ++++++++
>  arch/sh/boot/compressed/head_64.S      | 4 ++++
>  arch/sh/boot/compressed/misc.c         | 7 -------
>  7 files changed, 20 insertions(+), 21 deletions(-)

Perhaps this should be split into three patches and each one routed via
the appropriate arch tree maintainer (for sh, that might be me).

But we can do it this way if the arm and mips teams can send an ack,
please?
