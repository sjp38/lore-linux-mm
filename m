Subject: Re: Avoiding external fragmentation with a placement policy
	Version 12
From: Nick Piggin <nickpiggin@yahoo.com.au>
In-Reply-To: <429F2B26.9070509@austin.ibm.com>
References: <20050531112048.D2511E57A@skynet.csn.ul.ie>
	 <429E20B6.2000907@austin.ibm.com> <429E4023.2010308@yahoo.com.au>
	 <423970000.1117668514@flay> <429E483D.8010106@yahoo.com.au>
	 <434510000.1117670555@flay> <429E50B8.1060405@yahoo.com.au>
	 <429F2B26.9070509@austin.ibm.com>
Content-Type: text/plain
Date: Fri, 03 Jun 2005 13:48:08 +1000
Message-Id: <1117770488.5084.25.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jschopp@austin.ibm.com
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-06-02 at 10:52 -0500, Joel Schopp wrote:
> > I see your point... Mel's patch has failure cases though.
> > For example, someone turns swap off, or mlocks some memory
> > (I guess we then add the page migration defrag patch and
> > problem is solved?).
> 
> This reminds me that page migration defrag will be pretty useless 
> without something like this done first.  There will be stuff that can't 
> be migrated and it needs to be grouped together somehow.
> 
> In summary here are the reasons I see to run with Mel's patch:
> 
> 1. It really helps with medium-large allocations under memory pressure.
> 2. Page migration defrag will need it.
> 3. Memory hotplug remove will need it.
> 

I guess I'm now more convinced of its need ;)

add:
4. large pages
5. (hopefully) helps with smaller allocations (ie. order 3)

It would really help your cause in the short term if you can
demonstrate improvements for say order-3 allocations (eg. use
gige networking, TSO, jumbo frames, etc).


> On the downside we have:
> 
> 1. Slightly more complexity in the allocator.
> 

For some definitions of 'slightly', perhaps :(

Although I can't argue that a buddy allocator is no good without
being able to satisfy higher order allocations.

So in that case, I'm personally OK with it going into -mm. Hopefully
there will be a bit more review and hopefully some simplification if
possible.

Last question: how does it go on systems with really tiny memories?
(4MB, 8MB, that kind of thing).

> I'd personally trade a little extra complexity for any of the 3 upsides.
> 

-- 
SUSE Labs, Novell Inc.




Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
