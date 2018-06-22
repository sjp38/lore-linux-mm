Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED0DF6B000D
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:58:42 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k9-v6so594646edr.1
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 08:58:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s11-v6si3951051edh.359.2018.06.22.08.58.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 08:58:41 -0700 (PDT)
Date: Fri, 22 Jun 2018 17:58:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] kasan: depend on CONFIG_SLUB_DEBUG
Message-ID: <20180622155839.GF10465@dhcp22.suse.cz>
References: <CALvZod7Rf0FZHqYBPd1OTkVuvA5QRrkYQku40QJtS2--g6PrQQ@mail.gmail.com>
 <20180622154623.25388-1-Jason@zx2c4.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622154623.25388-1-Jason@zx2c4.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Shakeel Butt <shakeelb@google.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 22-06-18 17:46:23, Jason A. Donenfeld wrote:
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

This is the simplest way to do but I strongly suspect that the whole
SLUB_DEBUG is not really necessary

Acked-by: Michal Hocko <mhocko@suse.com>

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
>  	bool "KASan: runtime memory debugger"
>  	depends on SLUB || (SLAB && !DEBUG_SLAB)
> +	select SLUB_DEBUG if SLUB
>  	select CONSTRUCTORS
>  	select STACKDEPOT
>  	help
> -- 
> 2.17.1

-- 
Michal Hocko
SUSE Labs
