Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 020CF6B0010
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 12:10:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q8-v6so1256739wmc.2
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 09:10:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x14-v6sor4058438wrq.66.2018.06.22.09.10.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 09:10:44 -0700 (PDT)
MIME-Version: 1.0
References: <CALvZod7Rf0FZHqYBPd1OTkVuvA5QRrkYQku40QJtS2--g6PrQQ@mail.gmail.com>
 <20180622154623.25388-1-Jason@zx2c4.com>
In-Reply-To: <20180622154623.25388-1-Jason@zx2c4.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 22 Jun 2018 09:10:31 -0700
Message-ID: <CALvZod5Hio2kNqz90Z9_1JGxZHHpF89ax+joCHD4sJ87O_6kuw@mail.gmail.com>
Subject: Re: [PATCH] kasan: depend on CONFIG_SLUB_DEBUG
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A . Donenfeld" <Jason@zx2c4.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, stable@vger.kernel.org, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 22, 2018 at 8:46 AM Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>
> KASAN depends on having access to some of the accounting that SLUB_DEBUG
> does; without it, there are immediate crashes [1]. So, the natural thing
> to do is to make KASAN select SLUB_DEBUG.
>
> [1] http://lkml.kernel.org/r/CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com
>
> Fixes: f9e13c0a5a33 ("slab, slub: skip unnecessary kasan_cache_shutdown()")
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: <stable@vger.kernel.org>
> Cc: <linux-mm@kvack.org>
> Cc: <linux-kernel@vger.kernel.org>
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  lib/Kconfig.kasan | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index 3d35d062970d..c253c1b46c6b 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -6,6 +6,7 @@ if HAVE_ARCH_KASAN
>  config KASAN
>         bool "KASan: runtime memory debugger"
>         depends on SLUB || (SLAB && !DEBUG_SLAB)
> +       select SLUB_DEBUG if SLUB
>         select CONSTRUCTORS
>         select STACKDEPOT
>         help
> --
> 2.17.1
>
