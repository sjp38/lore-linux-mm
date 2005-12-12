Message-ID: <439CFC67.4030107@yahoo.com.au>
Date: Mon, 12 Dec 2005 15:28:23 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC 1/6] Framework
References: <20051210005440.3887.34478.sendpatchset@schroedinger.engr.sgi.com> <20051210005445.3887.94119.sendpatchset@schroedinger.engr.sgi.com> <439CF2A2.60105@yahoo.com.au> <20051212035631.GX11190@wotan.suse.de> <439CF93D.5090207@yahoo.com.au> <20051212042142.GZ11190@wotan.suse.de>
In-Reply-To: <20051212042142.GZ11190@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Mon, Dec 12, 2005 at 03:14:53PM +1100, Nick Piggin wrote:

>>Cool. That is a patch that should go on top of mine, because most of
>>my patch is aimed at moving modifications under interrupts-off sections,
> 
> 
> That's obsolete then.

No it isn't.

> With local_t you don't need to turn off interrupts
> anymore.
> 

Then you can't use __local_xxx, and so many architectures will use
atomic instructions (the ones who don't are the ones with tripled
cacheline footprint of this structure).

Sure i386 and x86-64 are happy, but this would probably slow down
most other architectures.

> 
>>However I'm still worried about the use of locals tripling the cacheline
>>size of a hot-path structure on some 64-bit architectures. Probably we
>>should get them to try to move to the atomic64 scheme before using
>>local_t here.
> 
> 
> I think the right fix for those is to just change the fallback local_t
> to disable interrupts again - that should be a better tradeoff and
> when they have a better alternative they can implement it in the arch.
> 

Probably right.

> (in fact i did a patch for that too, but considered throwing it away
> again because I don't have a good way to test it) 
> 

Yep, it will be difficult to test.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
