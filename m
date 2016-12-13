Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB476B0069
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 22:39:59 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j128so149367328pfg.4
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 19:39:59 -0800 (PST)
Received: from helcar.apana.org.au (helcar.hengli.com.au. [209.40.204.226])
        by mx.google.com with ESMTPS id s3si46321836pfe.68.2016.12.12.19.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 19:39:58 -0800 (PST)
Date: Tue, 13 Dec 2016 11:39:42 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Remaining crypto API regressions with CONFIG_VMAP_STACK
Message-ID: <20161213033942.GC5601@gondor.apana.org.au>
References: <20161209230851.GB64048@google.com>
 <CALCETrWfa5VJQNu3XjeFhF0cDFWF+M-dPwsT_7dzO5YSxsneGg@mail.gmail.com>
 <1747e6e9-35dc-48cc-7345-4f0412ba2521@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1747e6e9-35dc-48cc-7345-4f0412ba2521@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gary R Hook <ghook@amd.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Eric Biggers <ebiggers3@gmail.com>, linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Andrew Lutomirski <luto@kernel.org>, Stephan Mueller <smueller@chronox.de>

On Mon, Dec 12, 2016 at 12:45:18PM -0600, Gary R Hook wrote:
> On 12/12/2016 12:34 PM, Andy Lutomirski wrote:
> 
> <...snip...>
> 
> >
> >I have a patch to make these depend on !VMAP_STACK.
> >
> >>        drivers/crypto/ccp/ccp-crypto-aes-cmac.c:105,119,142
> >>        drivers/crypto/ccp/ccp-crypto-sha.c:95,109,124
> >>        drivers/crypto/ccp/ccp-crypto-aes-xts.c:162
> >>        drivers/crypto/ccp/ccp-crypto-aes.c:94
> >
> >According to Herbert, these are fine.  I'm personally less convinced
> >since I'm very confused as to what "async" means in the crypto code,
> >but I'm going to leave these alone.
> 
> I went back through the code, and AFAICT every argument to sg_init_one() in
> the above-cited files is a buffer that is part of the request context. Which
> is allocated by the crypto framework, and therefore will never be on the
> stack.
> Right?

Right.

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
