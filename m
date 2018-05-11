Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDB3E6B064B
	for <linux-mm@kvack.org>; Thu, 10 May 2018 20:02:36 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id x85-v6so2660798vke.11
        for <linux-mm@kvack.org>; Thu, 10 May 2018 17:02:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z41-v6sor842750uad.290.2018.05.10.17.02.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 May 2018 17:02:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180509200223.22451-1-keescook@chromium.org>
References: <20180509200223.22451-1-keescook@chromium.org>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 10 May 2018 17:02:34 -0700
Message-ID: <CAGXu5j+0WKjetgxxdE4HUi9mDjnWm+taNLnYio1VgpAeCutpJg@mail.gmail.com>
Subject: Re: [PATCH v2 0/6] Provide saturating helpers for allocation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <mawilcox@microsoft.com>, Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, May 9, 2018 at 1:02 PM, Kees Cook <keescook@chromium.org> wrote:
> This is a stab at providing three new helpers for allocation size
> calculation:
>
> struct_size(), array_size(), and array3_size().
>
> These are implemented on top of Rasmus's overflow checking functions. The
> existing allocators are adjusted to use the more efficient overflow
> checks as well.
>
> I have left out the 8 tree-wide conversion patches of open-coded
> multiplications into the new helpers, as those are largely
> unchanged from v1. Everything can be seen here, though:
> https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/log/?h=kspp/overflow/array_size
>
> The question remains for what to do with the *calloc() and *_array*()
> API. They could be entirely removed in favor of using the new helpers:
>
> kcalloc(n, size, gfp)        ->  kzalloc(array_size(n, size), gfp)
> kmalloc_array(n, size, gfp)  ->  kmalloc(array_size(n, size), gfp)
>
> Changes from v1:
> - use explicit overflow helpers instead of array_size() helpers.
> - drop early-checks for SIZE_MAX.
> - protect devm_kmalloc()-family from addition overflow.
> - added missing overflow.h includes.
> - fixed 0-day issues in a few treewide manual conversions

I've added an allocation overflow addition to lib/test_overflow now,
so I'll send a v3 soon. Does anyone want to provide an Ack or Reviewed
for these?

Also, any thoughts on *calloc() and *_array*() removal?

-Kees

-- 
Kees Cook
Pixel Security
