Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 49E896B0038
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 15:07:22 -0400 (EDT)
Received: by mail-oi0-f44.google.com with SMTP id x69so6889740oia.3
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 12:07:22 -0700 (PDT)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id ow18si31048740oeb.94.2014.08.12.12.07.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 12:07:21 -0700 (PDT)
Received: by mail-ob0-f179.google.com with SMTP id wn1so7497820obc.38
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 12:07:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140809030822.GA9422@gondor.apana.org.au>
References: <20140808075316.GA21919@www.outflux.net>
	<CALZtONBNEg7kzUtwKihQuAU48MNh5NjhZcWoOxe-1-vgWqSLiw@mail.gmail.com>
	<CAGXu5jL3GjrqsixS6U+GYD1pxAOOcXsXbt5XOVC8KhZB+naXAA@mail.gmail.com>
	<20140809030822.GA9422@gondor.apana.org.au>
Date: Tue, 12 Aug 2014 12:07:21 -0700
Message-ID: <CAGXu5jLMYKB3xmRd3qOZUSRoJwM7r-s3O+asECvLn4-vyjCKLA@mail.gmail.com>
Subject: Re: [PATCH] mm/zpool: use prefixed module loading
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Dan Streetman <ddstreet@ieee.org>, Greg KH <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Linux-MM <linux-mm@kvack.org>, Vasiliy Kulikov <segoon@openwall.com>

On Fri, Aug 8, 2014 at 8:08 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
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

Okay, I'll see the zpool patch again with the aliases moved into the
ZPOOL ifdef, and I'll start working on a crypto patch set to solve the
prefix there too.

Thanks!

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
