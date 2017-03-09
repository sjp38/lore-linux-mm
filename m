Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 47BB42808B4
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 04:40:09 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g2so103565080pge.7
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 01:40:09 -0800 (PST)
Received: from helcar.apana.org.au (helcar.hengli.com.au. [209.40.204.226])
        by mx.google.com with ESMTPS id i6si5939197plk.296.2017.03.09.01.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 01:40:08 -0800 (PST)
Date: Thu, 9 Mar 2017 17:39:54 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 1/1] mm: zswap - Add crypto acomp/scomp framework
 support
Message-ID: <20170309093954.GA6567@gondor.apana.org.au>
References: <1487952313-22381-1-git-send-email-Mahipal.Challa@cavium.com>
 <1487952313-22381-2-git-send-email-Mahipal.Challa@cavium.com>
 <CALZtONBeS7bAjxpbLDdQj=y_tsXUX5TVCFdqbQ3LccTSa6kfnw@mail.gmail.com>
 <CALyTkE9=oU1dd+CLmBceHjeO965QYWWUk98L1MNoiwrDbpypcg@mail.gmail.com>
 <CALZtONBuQJN3Qrd-RP4_TAD=OeWNO8quPYpN+=Gsz2byAxWFPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONBuQJN3Qrd-RP4_TAD=OeWNO8quPYpN+=Gsz2byAxWFPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Mahipal Reddy <mahipalreddy2006@gmail.com>, Mahipal Challa <Mahipal.Challa@cavium.com>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, pathreya@cavium.com, Vishnu Nair <Vishnu.Nair@cavium.com>

On Wed, Mar 08, 2017 at 12:38:40PM -0500, Dan Streetman wrote:
> 
> It looks like the crypto_scomp interface is buried under
> include/crypto/internal/scompress.h, however that's exactly what zswap
> should be using.  We don't need to switch to an asynchronous interface
> that's rather significantly more complicated, and then use it in a
> synchronous way.  The crypto_scomp interface should probably be made
> public, not an implementation internal.

No scomp is not meant to be used externally.  We provide exactly
one compression interface and it's acomp.  acomp can be used
synchronously by setting the CRYPTO_ALG_ASYNC bit in the mask
field when allocating the algorithm.

The existing compression interface will be phased out.

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
