Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A43576B0266
	for <linux-mm@kvack.org>; Sat, 10 Dec 2016 00:37:28 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so87956715pgc.2
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 21:37:28 -0800 (PST)
Received: from helcar.apana.org.au (helcar.hengli.com.au. [209.40.204.226])
        by mx.google.com with ESMTPS id 1si36351806pgy.294.2016.12.09.21.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 21:37:27 -0800 (PST)
Date: Sat, 10 Dec 2016 13:37:12 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Remaining crypto API regressions with CONFIG_VMAP_STACK
Message-ID: <20161210053711.GB27951@gondor.apana.org.au>
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
> Herbert, how hard would it be to teach the crypto code to use a more
> sensible data structure than scatterlist and to use coccinelle fix
> this stuff for real?

First of all we already have a sync non-SG hash interface, it's
called shash.

If we had enough sync-only users of skcipher then I'll consider
adding an interface for it.  However, at this point in time it
appears to more sense to convert such users over to the async
interface rather than the other way around.

As for AEAD we never had a sync interface to begin with and I
don't think I'm going to add one.

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
