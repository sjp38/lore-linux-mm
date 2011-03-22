Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 243BF8D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 05:04:06 -0400 (EDT)
Date: Tue, 22 Mar 2011 17:03:50 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/8] drivers/random: Cache align ip_random better
Message-ID: <20110322090350.GA23736@gondor.apana.org.au>
References: <alpine.LSU.2.00.1103161123360.14076@sister.anvils> <20110316194542.22530.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110316194542.22530.qmail@science.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, penberg@cs.helsinki.fi

On Wed, Mar 16, 2011 at 03:45:42PM -0400, George Spelvin wrote:
>
> > Ah, now you come clean!  Yes, it does feel neater to me too;
> > but I doubt that would be sufficient justification by itself.
> 
> It took both factors to make it worth it to me.  The real reason was:
> 1) Neater
> 2) Definitely not slower
> 3) Maybe a tiny bit faster
> Conclusion: do it.

I'm with Hugh on this, the justification seems pretty weak.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
