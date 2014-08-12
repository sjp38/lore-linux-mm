Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 481FC6B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 20:42:32 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so5081217wiv.5
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 17:42:31 -0700 (PDT)
Received: from mail-wg0-x22c.google.com (mail-wg0-x22c.google.com [2a00:1450:400c:c00::22c])
        by mx.google.com with ESMTPS id cl3si14425401wib.69.2014.08.11.17.42.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 17:42:30 -0700 (PDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so9210826wgh.15
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 17:42:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140809030822.GA9422@gondor.apana.org.au>
References: <20140808075316.GA21919@www.outflux.net> <CALZtONBNEg7kzUtwKihQuAU48MNh5NjhZcWoOxe-1-vgWqSLiw@mail.gmail.com>
 <CAGXu5jL3GjrqsixS6U+GYD1pxAOOcXsXbt5XOVC8KhZB+naXAA@mail.gmail.com> <20140809030822.GA9422@gondor.apana.org.au>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 11 Aug 2014 20:42:10 -0400
Message-ID: <CALZtONCRexP81eAAGEDt39g=WS=Dw7UOp0L-ip_SHSpaSE8QzA@mail.gmail.com>
Subject: Re: [PATCH] mm/zpool: use prefixed module loading
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Linux-MM <linux-mm@kvack.org>, Vasiliy Kulikov <segoon@openwall.com>, Herbert Xu <herbert@gondor.apana.org.au>

Ok if the crypto request_module is changed it makes more sense to
change zpool's use of request_module; it looks like there are a couple
other places in the kernel using prefixes/aliases (although it's not
universal).  I still suggest moving the MODULE_ALIAS() into
zbud/zsmalloc's #ifdef CONFIG_ZPOOL, though.


On Fri, Aug 8, 2014 at 11:08 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Fri, Aug 08, 2014 at 05:06:41PM -0700, Kees Cook wrote:
>>
>> I think we need to fix zswap now before it gets too far, and likely
>> adjust the crypto API to use a module prefix as well. Perhaps we need
>> a "crypto-" prefix?
>
> Yes I think a crypto- prefix would make sense.  Most crypto
> algorithms should be providing an alias already so it's mostly
> just changing the aliases.
>
> Patches are welcome :)
>
> Thanks,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
