Message-ID: <4471899B.1000404@yahoo.com.au>
Date: Mon, 22 May 2006 19:51:23 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2/2] mm: handle unaligned zones
References: <4470232B.7040802@yahoo.com.au> <44702358.1090801@yahoo.com.au> <20060521021905.0f73e01a.akpm@osdl.org> <4470417F.2000605@yahoo.com.au> <20060521035906.3a9997b0.akpm@osdl.org> <44705291.9070105@yahoo.com.au> <Pine.LNX.4.64.0605221000480.14117@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0605221000480.14117@skynet.skynet.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@osdl.org>, apw@shadowen.org, stable@kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Sun, 21 May 2006, Nick Piggin wrote:
> 
>> Andrew Morton wrote:
>>
>>> How about just throwing the pages away?  It sounds like a pretty rare
>>> problem.
>>
>>
>> Well that's what many architectures will end up doing, yes. But on
>> small or embedded platforms, 4MB - 1 is a whole lot of memory to be
>> throwing away.
>>
>> Also, I'm not sure it is something we can be doing in generic code,
>> because some architectures apparently have very strange zone setups
>> (eg. zones from several pages interleaved within a single zone's
>> ->spanned_pages).
> 
> 
> I looked through a fair few arches code that sizes zones and I couldn't 
> find this or odd calls to set_page_links(). What arch interleaves pages 
> between zones like this? I am taking you mean that you can have a 
> situation where within one contiguous block of pages you have something 
> like;
> 
> dddNNNdddNNNddd
> 
> Where d is a page in ZONE_DMA and N is a page in ZONE_NORMAL.
> 
> The oddest I've seen is where nodes interleave like on PPC64. There you 
> can have pages for node 0 followed by pages for node 1 followed by node 
> 0 again. But the zone start and end pfns stay in the same place.

Depending on how you look, ZONE_DMA and ZONE_NORMAL aren't always "zones" :)

I'm talking about struct zones, rather than zones-as-in-memory-classes.
So yes, PPC64 is my example. Andy's zone index check should take care
of those.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
