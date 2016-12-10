Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB3316B025E
	for <linux-mm@kvack.org>; Sat, 10 Dec 2016 00:32:28 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 3so88526876pgd.3
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 21:32:28 -0800 (PST)
Received: from helcar.apana.org.au (helcar.hengli.com.au. [209.40.204.226])
        by mx.google.com with ESMTPS id j15si36450636pli.53.2016.12.09.21.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 21:32:28 -0800 (PST)
Date: Sat, 10 Dec 2016 13:32:08 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Remaining crypto API regressions with CONFIG_VMAP_STACK
Message-ID: <20161210053208.GA27951@gondor.apana.org.au>
References: <20161209230851.GB64048@google.com>
 <CALCETrW=+3u3P8Xva+0ck9=fr-mD6azPtTkOQ3uQO+GoOA6FcQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrW=+3u3P8Xva+0ck9=fr-mD6azPtTkOQ3uQO+GoOA6FcQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Andrew Lutomirski <luto@kernel.org>, Stephan Mueller <smueller@chronox.de>

On Fri, Dec 09, 2016 at 09:25:38PM -0800, Andy Lutomirski wrote:
>
> > The following crypto drivers initialize a scatterlist to point into an
> > ablkcipher_request, which may have been allocated on the stack with
> > SKCIPHER_REQUEST_ON_STACK():
> >
> >         drivers/crypto/ccp/ccp-crypto-aes-xts.c:162
> >         drivers/crypto/ccp/ccp-crypto-aes.c:94
> 
> These are real, and I wish I'd known about them sooner.

Are you sure? Any instance of *_ON_STACK must only be used with
sync algorithms and most drivers under drivers/crypto declare
themselves as async.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
