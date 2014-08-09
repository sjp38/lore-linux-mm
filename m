Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A5EA76B0036
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 23:09:04 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so8223970pab.14
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 20:09:04 -0700 (PDT)
Received: from helcar.apana.org.au (helcar.apana.org.au. [209.40.204.226])
        by mx.google.com with ESMTPS id he1si7439679pbd.172.2014.08.08.20.09.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 08 Aug 2014 20:09:03 -0700 (PDT)
Date: Sat, 9 Aug 2014 11:08:22 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] mm/zpool: use prefixed module loading
Message-ID: <20140809030822.GA9422@gondor.apana.org.au>
References: <20140808075316.GA21919@www.outflux.net>
 <CALZtONBNEg7kzUtwKihQuAU48MNh5NjhZcWoOxe-1-vgWqSLiw@mail.gmail.com>
 <CAGXu5jL3GjrqsixS6U+GYD1pxAOOcXsXbt5XOVC8KhZB+naXAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jL3GjrqsixS6U+GYD1pxAOOcXsXbt5XOVC8KhZB+naXAA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Greg KH <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Linux-MM <linux-mm@kvack.org>, Vasiliy Kulikov <segoon@openwall.com>

On Fri, Aug 08, 2014 at 05:06:41PM -0700, Kees Cook wrote:
>
> I think we need to fix zswap now before it gets too far, and likely
> adjust the crypto API to use a module prefix as well. Perhaps we need
> a "crypto-" prefix?

Yes I think a crypto- prefix would make sense.  Most crypto
algorithms should be providing an alias already so it's mostly
just changing the aliases.

Patches are welcome :)

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
