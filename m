Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 209036B004F
	for <linux-mm@kvack.org>; Sat,  4 Jul 2009 23:19:52 -0400 (EDT)
Date: Sun, 5 Jul 2009 11:44:48 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: QUESTION: can netdev_alloc_skb() errors be reduced  by  tuning?
Message-ID: <20090705034448.GA7588@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A3737CE.3020305@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: starlight@binnacle.cx, linux-kernel@vger.kernel.org, mel@csn.ul.ie, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, Lee.Schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, ebmunson@us.ibm.com, agl@us.ibm.com, apw@canonical.com, wli@movementarian.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> Because of slab rounding, this reallocation should be done only if resulting data
> portion is really smaller (50 %) than original skb.

If we're going to do this in the core then we should only do it
in the spots where the packet may be held indefinitely.

Cheers,
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
