Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA2E6B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 23:53:56 -0500 (EST)
Date: Fri, 20 Feb 2009 12:53:27 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 2/7] crypto: use kzfree()
Message-ID: <20090220045327.GA17680@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090217184135.837159784@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, penberg@cs.helsinki.fi, chas@cmf.nrl.navy.mil, johnpol@2ka.mipt.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> wrote:
> Use kzfree() instead of memset() + kfree().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
