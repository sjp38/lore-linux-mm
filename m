Message-ID: <39AA30AF.14C17C50@tuke.sk>
Date: Mon, 28 Aug 2000 11:28:15 +0200
From: Jan Astalos <astalos@tuke.sk>
MIME-Version: 1.0
Subject: Re: Question: memory management and QoS
References: <39A4F548.B8EB5308@tuke.sk> <20000828154744.A3741@saw.sw.com.sg>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrey Savochkin <saw@saw.sw.com.sg>
Cc: linux-mm@kvack.org, Yuri Pudgorodsky <yur@asplinux.ru>
List-ID: <linux-mm.kvack.org>

Andrey Savochkin wrote:
> 
> Hello,

Hi.

>  
> I don't think that personal swapfiles is an efficient approach to achieve
> QoS.  Most of the space will be reserved for exceptional cases, and, thus,
> wasted, as Yuri has mentioned.  A shared swap space allowing exceeding the
> guaranteed amount (if the memory isn't really used) is much more efficient
> spending of the space.  If the system has some spare memory, users exceeding
> their limits may still use it (but, certainly, only if only some of them, not
> all, exceed the limits).  Moreover, if some users don't consume all the
> memory guaranteed to them, others may temporarily use it.

I think I explained my points clearly enough in my second reply to Yuri so I won't 
repeat it again. 

I still claim that per user swapfiles will:
- be _much_ more efficient in the sense of wasting disk space (saving money)
  because it will teach users efficiently use their memory resources (if
  user will waste the space inside it's own disk quota it will be his own
  problem)
- provide QoS on VM memory allocation to users (will guarantee amount of
  available VM for user)
- be able to improve _per_user_ performance of system (localizing performance
  problems to users that caused them and reducing disk seek times)
- shift the problem with OOM from system to user.

Please, don't repeat Yuri's argument with unswapable kernel objects and locked
memory. Users should be able to lock only memory inside their own allocation
and kernel objects should be accounted to this kind of memory too. Whether
it is easy or hard to implement really does not matter for design. Anyway, there
still could be pool of memory allocated to anonymous objects...

I think that your beancounter is a big step towards good QoS in Linux MM, but
I'm a bit confused when I'll hear "...users exceeding their limits". What's the
limit good for if it can be exceeded ? Can you rethought the term ?

Can you describe how to avoid VM shortage by beancounter ? 
Other than I described in my first reply to Yuri (point A) .

Regards, 
Jan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
