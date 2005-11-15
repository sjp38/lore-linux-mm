Message-ID: <4379B0A7.3090803@yahoo.com.au>
Date: Tue, 15 Nov 2005 20:55:51 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 03/05] mm rationalize __alloc_pages ALLOC_* flag names
References: <20051114040329.13951.39891.sendpatchset@jackhammer.engr.sgi.com>	<20051114040353.13951.82602.sendpatchset@jackhammer.engr.sgi.com>	<4379A399.1080407@yahoo.com.au> <20051115010303.6bc04222.akpm@osdl.org>
In-Reply-To: <20051115010303.6bc04222.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: pj@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Simon.Derr@bull.net, clameter@sgi.com, rohit.seth@intel.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>Paul Jackson wrote:
>>
>>>Rationalize mm/page_alloc.c:__alloc_pages() ALLOC flag names.
>>>
>>
>>I don't really see the need for this. The names aren't
>>clearly better, and the downside is that they move away
>>from the terminlogy we've been using in the page allocator
>>for the past few years.
> 
> 
> I thought they were heaps better, actually.
> 

Some? Alot? Musthave?

To me it just changed the manner in which the hands are waving.
Actually, I like the current names because ALLOC_HIGH explicitly
is used for __GFP_HIGH allocations, and MUSTHAVE is not really
an improvement on NO_WATERMARKS.

However if you'd really like to change the names, I'd prefer them
to be more consistent, eg:

ALLOC_DIP_NONE
ALLOC_DIP_LESS
ALLOC_DIP_MORE
ALLOC_DIP_FULL

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
