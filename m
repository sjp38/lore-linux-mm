Message-ID: <439CF3B1.4050803@yahoo.com.au>
Date: Mon, 12 Dec 2005 14:51:13 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC 3/6] Make nr_pagecache a per zone counter
References: <20051210005440.3887.34478.sendpatchset@schroedinger.engr.sgi.com> <20051210005456.3887.94412.sendpatchset@schroedinger.engr.sgi.com> <20051211183241.GD4267@dmt.cnet> <20051211194840.GU11190@wotan.suse.de> <20051211204943.GA4375@dmt.cnet>
In-Reply-To: <20051211204943.GA4375@dmt.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> On Sun, Dec 11, 2005 at 08:48:40PM +0100, Andi Kleen wrote:
> 
>>>By the way, why does nr_pagecache needs to be an atomic variable on UP systems?
>>
>>At least on X86 UP atomic doesn't use the LOCK prefix and is thus quite
>>cheap. I would expect other architectures who care about UP performance
>>(= not IA64) to be similar.
> 
> 
> But in practice the variable does not need to be an atomic type for UP, but
> simply a word, since stores are atomic on UP systems, no?
> 
> Several arches seem to use additional atomicity instructions on 
> atomic functions:
> 

Yeah, this is to protect from interrupts and is common to most
load store architectures. It is possible we could have
atomic_xxx_irq / atomic_xxx_irqsave functions for these, however
I think nobody has yet demostrated the improvements outweigh the
complexity that would be added.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
