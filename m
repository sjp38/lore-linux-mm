Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EBB5B6B0025
	for <linux-mm@kvack.org>; Tue, 17 May 2011 15:22:20 -0400 (EDT)
Date: Tue, 17 May 2011 22:22:15 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [slubllv5 03/25] slub: Make CONFIG_PAGE_ALLOC work with new
 fastpath
In-Reply-To: <alpine.DEB.2.00.1105170845410.11187@router.home>
Message-ID: <alpine.DEB.2.00.1105172222050.7203@tiger>
References: <20110516202605.274023469@linux.com>   <20110516202622.862544137@linux.com>  <1305607974.9466.42.camel@edumazet-laptop> <alpine.DEB.2.00.1105170845410.11187@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On Tue, 17 May 2011, Christoph Lameter wrote:

> On Tue, 17 May 2011, Eric Dumazet wrote:
>
>> Some credits would be good, it would certainly help both of us.
>
> True. Sorry I just posted my queue without integrating tags.
>
>> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
>>
>>> Signed-off-by: Christoph Lameter <cl@linux.com>
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, with fixed changelog. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
