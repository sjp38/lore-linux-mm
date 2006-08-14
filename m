Message-ID: <44E08730.8080702@redhat.com>
Date: Mon, 14 Aug 2006 10:22:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/4] VM deadlock prevention -v4
References: <E1GCbux-0005CO-00@gondolin.me.apana.org.au>
In-Reply-To: <E1GCbux-0005CO-00@gondolin.me.apana.org.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: johnpol@2ka.mipt.ru, phillips@google.com, a.p.zijlstra@chello.nl, indan@nul.nu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Herbert Xu wrote:
> Rik van Riel <riel@redhat.com> wrote:
>> That should not be any problem, since skb's (including cowed ones)
>> are short lived anyway.  Allocating a little bit more memory is
>> fine when we have a guarantee that the memory will be freed again
>> shortly.
> 
> I'm not sure about the context the comment applies to, but skb's are
> not necessarily short-lived.  For example, they could be queued for
> a few seconds for ARP/NDISC and even longer for IPsec SA resolution.

That's still below the threshold where it should cause problems
with the VM going OOM.  Especially if there aren't too many of
these packets.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
