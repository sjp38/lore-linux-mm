Message-ID: <463B978C.6050303@garzik.org>
Date: Fri, 04 May 2007 16:29:00 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [PATCH 00/40] Swap over Networked storage -v12
References: <20070504102651.923946304@chello.nl>	<20070504.122716.31641374.davem@davemloft.net>	<1178307709.2767.19.camel@lappy> <20070504.130239.38710262.davem@davemloft.net>
In-Reply-To: <20070504.130239.38710262.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>, a.p.zijlstra@chello.nl
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, tgraf@suug.ch, James.Bottomley@SteelEye.com, michaelc@cs.wisc.edu, akpm@linux-foundation.org, phillips@google.com
List-ID: <linux-mm.kvack.org>

David Miller wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Fri, 04 May 2007 21:41:49 +0200
> 
>> How would you prefer I present these?
> 
> How about 8 or 9 at a time?  You are building infrastructure
> and therefore you could post them 1 at a time for review
> since each patch should be able to stand on it's own.

Indeed.  Just glancing over the patchset, there are quite a few "easy to 
apply" cleanup patches that could be fast-forwarded to upstream, without 
requiring deep thought on the swap-over-storage MM changes or net 
allocator changes.

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
