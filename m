Message-ID: <419EF8F2.1050909@yahoo.com.au>
Date: Sat, 20 Nov 2004 18:57:38 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: page fault scalability patch V11 [0/7]: overview
References: <20041120020306.GA2714@holomorphy.com> <419EBBE0.4010303@yahoo.com.au> <20041120035510.GH2714@holomorphy.com> <419EC205.5030604@yahoo.com.au> <20041120042340.GJ2714@holomorphy.com> <419EC829.4040704@yahoo.com.au> <20041120053802.GL2714@holomorphy.com> <419EDB21.3070707@yahoo.com.au> <20041120062341.GM2714@holomorphy.com> <419EE911.20205@yahoo.com.au> <20041120071514.GO2714@holomorphy.com> <419EF257.8010103@yahoo.com.au>
In-Reply-To: <419EF257.8010103@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> William Lee Irwin III wrote:

>> No, it's on-topic.
>> (1) The issue is not theoretical. e.g. sysrq t does trigger NMI oopses,
>>     merely not every time, and not on every system. It is not
>>     associated with hardware failure. It is, however, tolerable
>>     because sysrq's require privilege to trigger and are primarly
>>     used when the box is dying anyway.
> 
> 
> OK then put a touch_nmi_watchdog in there if you must.
> 

Duh, there is one in there :\

Still, that doesn't really say much about a normal tasklist traversal
because this thing will spend ages writing stuff to serial console.

Now I know going over the whole tasklist is crap. Anything O(n) for
things like this is crap. I happen to just get frustrated to see
concessions being made to support more efficient /proc access. I know
you are one of the ones who has to deal with the practical realities
of that though. Sigh. Well try to bear with me... :|
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
