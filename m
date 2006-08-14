From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH 0/4] VM deadlock prevention -v4
In-Reply-To: <44E06AC7.6090301@redhat.com>
Message-Id: <E1GCbux-0005CO-00@gondolin.me.apana.org.au>
Date: Mon, 14 Aug 2006 22:51:43 +1000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: johnpol@2ka.mipt.ru, phillips@google.com, a.p.zijlstra@chello.nl, indan@nul.nu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@redhat.com> wrote:
> 
> That should not be any problem, since skb's (including cowed ones)
> are short lived anyway.  Allocating a little bit more memory is
> fine when we have a guarantee that the memory will be freed again
> shortly.

I'm not sure about the context the comment applies to, but skb's are
not necessarily short-lived.  For example, they could be queued for
a few seconds for ARP/NDISC and even longer for IPsec SA resolution.

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
