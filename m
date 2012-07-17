Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B26A66B005A
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 20:41:04 -0400 (EDT)
Message-ID: <5004B49C.6010708@cesarb.net>
Date: Mon, 16 Jul 2012 21:41:00 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: frontswap: is frontswap_init called from swapoff safe?
References: <4FCDE270.1020906@cesarb.net> <20120607003720.GI9472@phenom.dumpdata.com>
In-Reply-To: <20120607003720.GI9472@phenom.dumpdata.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

Em 06-06-2012 21:37, Konrad Rzeszutek Wilk escreveu:
> On Tue, Jun 05, 2012 at 07:41:52AM -0300, Cesar Eduardo Barros wrote:
>> I was looking at the swapfile.c parts of the recently-merged
>> frontswap, and noticed that frontswap_init can be called from
>> swapoff when try_to_unuse fails.
>>
>> This looks odd to me. Whether it is safe or not depends on what
>> frontswap_ops.init does, but the comment for __frontswap_init
>> ("Called when a swap device is swapon'd") and the function name
>> itself seem to imply it should be called only for swapon, not when
>> relinking the swap_info after a failed swapoff.
>
> <nods>
>>
>> In particular, if frontswap_ops.init assumes the swap map is empty,
>> it would break, since as far as I know when try_to_unuse fails there
>> are still pages in the swap.
>
> Let me look at this - can't do it this week - but will get back to you
> shortly.

Did you look at it already? (Just pinging in case you forgot.)

>>
>> (By the way, the comment above enable_swap_info at sys_swapoff needs
>> to be updated to also explain why reading p->frontswap_map outside
>> the lock is safe at that point, like it does for p->prio and
>> p->swap_map.)

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
