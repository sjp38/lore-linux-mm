Message-ID: <3F6503BF.405@plasticpenguins.com>
Date: Sun, 14 Sep 2003 20:11:43 -0400
From: Mike S <wickedchicken@plasticpenguins.com>
MIME-Version: 1.0
Subject: Re: [RFC] Enabling other oom schemes
References: <200309120219.h8C2JANc004514@penguin.co.intel.com>	 <20030913174825.GB7404@mail.jlokier.co.uk> <1063476152.24473.30.camel@localhost>
In-Reply-To: <1063476152.24473.30.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Jamie Lokier <jamie@shareable.org>, rusty@linux.co.intel.com, riel@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Robert Love wrote:

> One thing to keep in mind is that during a real OOM condition, we cannot
> allocate _any_ memory.  None. Zilch.
> 
> And that makes some things very hard.  When we start getting into things
> such as complicated policies that kill nonessential services first, et
> cetera... there comes a time where a lot of communication is needed
> (probably with user-space).  Hard to do that with no memory.

A possible, but not very efficient workaround is to reserve memory or 
swap just for this condition. Obviously this limits available memory for 
other process (which in theory could cause an OOM in the first place) 
and would be wasted most of the time. Possibly this reserved memory 
would be used as a filesystem read cache until OOM, when it would be 
cleared out and used for whatever.

-- 

~Mike
wickedchicken@plasticpenguins.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
