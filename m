Message-ID: <44DE7C34.4080909@redhat.com>
Date: Sat, 12 Aug 2006 21:11:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
References: <1155374390.13508.15.camel@lappy>	<20060812093706.GA13554@2ka.mipt.ru>	<1155377887.13508.27.camel@lappy> <20060812.174651.113732891.davem@davemloft.net>
In-Reply-To: <20060812.174651.113732891.davem@davemloft.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, phillips@google.com
List-ID: <linux-mm.kvack.org>

David Miller wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Sat, 12 Aug 2006 12:18:07 +0200
> 
>> 65535 sockets * 128 packets * 16384 bytes/packet = 
>> 1^16 * 1^7 * 1^14 = 1^(16+7+14) = 1^37 = 128G of memory per IP
>>
>> And systems with a lot of IP numbers are not unthinkable.
> 
> TCP restricts the amount of global memory that may be consumed
> by all TCP sockets via the tcp_mem[] sysctl.

This is exactly why we need to be careful which sockets
we allocate memory for, when the system is about to run
out of memory.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
