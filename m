Date: Thu, 11 Nov 2004 09:42:17 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] fix spurious OOM kills
Message-ID: <318860000.1100194936@[10.10.2.4]>
In-Reply-To: <20041111165050.GA5822@x30.random>
References: <20041111112922.GA15948@logos.cnet> <20041111154238.GD18365@x30.random> <20041111123850.GA16349@logos.cnet> <20041111165050.GA5822@x30.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <piggin@cyberone.com.au>, Rik van Riel <riel@redhat.com>, Martin MOKREJ? <mmokrejs@ribosome.natur.cuni.cz>, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

>> > I disagree about the design of killing anything from kswapd. kswapd is
>> > an async helper like pdflush and it has no knowledge on the caller (it
>> > cannot know if the caller is ok with the memory currently available in
>> > the freelists, before triggering the oom). 
>> 
>> If zone_dma / zone_normal are below pages_min no caller is "OK with
>> memory currently available" except GFP_ATOMIC/realtime callers.
> 
> If the GFP_DMA zone is filled, and nobody allocates with GFP_DMA,
> nothing should be killed and everything should run fine, how can you
> get this right from kswapd?

Technically, that seems correct, but does it really matter much? We're 
talking about 

"it's full of unreclaimable stuff" vs
"it's full of unreclaimable stuff and someone tried to allocate a page".

So the difference is only ever one page, right? Doesn't really seem 
worth worrying about - we'll burn that in code space for the algorithms
to do this ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
