Message-ID: <4470547D.2030505@yahoo.com.au>
Date: Sun, 21 May 2006 21:52:29 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2/2] mm: handle unaligned zones
References: <4470232B.7040802@yahoo.com.au>	<44702358.1090801@yahoo.com.au>	<20060521021905.0f73e01a.akpm@osdl.org>	<4470417F.2000605@yahoo.com.au> <20060521035906.3a9997b0.akpm@osdl.org> <44705291.9070105@yahoo.com.au>
In-Reply-To: <44705291.9070105@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, apw@shadowen.org, mel@csn.ul.ie, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Andrew Morton wrote:
> 
>> How about just throwing the pages away?  It sounds like a pretty rare
>> problem.
> 
> 
> Well that's what many architectures will end up doing, yes. But on
> small or embedded platforms, 4MB - 1 is a whole lot of memory to be
> throwing away.
> 
> Also, I'm not sure it is something we can be doing in generic code,
> because some architectures apparently have very strange zone setups
> (eg. zones from several pages interleaved within a single zone's
> ->spanned_pages). So it doesn't sound like a simple matter of trying
> to override the zones' intervals.

Oh I see, yeah I guess you could throw away the pages forming the
present fraction of the MAX_ORDER buddy...

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

----- End forwarded message -----

-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
