Message-ID: <429E50B8.1060405@yahoo.com.au>
Date: Thu, 02 Jun 2005 10:20:08 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
References: <20050531112048.D2511E57A@skynet.csn.ul.ie> <429E20B6.2000907@austin.ibm.com> <429E4023.2010308@yahoo.com.au> <423970000.1117668514@flay> <429E483D.8010106@yahoo.com.au> <434510000.1117670555@flay>
In-Reply-To: <434510000.1117670555@flay>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: jschopp@austin.ibm.com, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:

> There's one example ... we can probably work around it if we try hard
> enough. However, the fundamental question becomes "do we support higher
> order allocs, or not?". If not fine ... but we ought to quit pretending
> we do. If so, then we need to make them more reliable.
> 

It appears that we basically support order 3 allocations and
less (those will stay in the page allocator until something
happens).

I see your point... Mel's patch has failure cases though.
For example, someone turns swap off, or mlocks some memory
(I guess we then add the page migration defrag patch and
problem is solved?).

I do see your point. The extra complexity makes me cringe though
(no offence to Mel - I'm sure it is a complex problem).

>>Yeah more or less. But with the fragmentation patch, it by
>>no means becomes an exact science ;) I wouldn't have thought
>>it would make it hugely easier to free an order 2 or 3 area
>>memory block on a loaded machine.
> 
> 
> Ummm. so the blunderbuss is an exact science? ;-) At least it fairly
> consistently doesn't work, I suppose ;-) ;-)
>  

No but I was just saying it is just another degree of
"unsuportedness" (or supportedness, if you are a half full man).

>>Why not just have kernel allocations going from the bottom
>>up, and user allocations going from the top down. That would
>>get you most of the way there, wouldn't it? (disclaimer: I
>>could well be talking shit here).
> 
> 
> Not sure it's quite that simple, though I haven't looked in detail
> at these patches. My point was merely that we need to do *something*.
> Off the top of my head ... what happens when kernel meets user in
> the middle. where do we free and allocate from now ? ;-) Once we've
> been up for a while, mem is nearly all used, nearly all of the time.
> 

No, I'm quite sure it isn't that simple, unfortunately. Hence
disclaimer ;)

> Is a good discussion to have though ;-)
> 

Yep, I was trying to help get something going!
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
