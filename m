Date: Wed, 01 Jun 2005 16:28:34 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: Avoiding external fragmentation with a placement policy Version 12
Message-ID: <423970000.1117668514@flay>
In-Reply-To: <429E4023.2010308@yahoo.com.au>
References: <20050531112048.D2511E57A@skynet.csn.ul.ie> <429E20B6.2000907@austin.ibm.com> <429E4023.2010308@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, jschopp@austin.ibm.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

--On Thursday, June 02, 2005 09:09:23 +1000 Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> Joel Schopp wrote:
> 
>> 
>> Other than the very minor whitespace changes above I have nothing bad to 
>> say about this patch.  I think it is about time to pick in up in -mm for 
>> wider testing.
>> 
> 
> It adds a lot of complexity to the page allocator and while
> it might be very good, the only improvement we've been shown
> yet is allocating lots of MAX_ORDER allocations I think? (ie.
> not very useful)

I agree that MAX_ORDER allocs aren't interesting, but we can hit 
frag problems easily at way less than max order. CIFS does it, NFS 
does it, jumbo frame gigabit ethernet does it, to name a few. The 
most common failure I see is order 3. 

Keep a machine up for a while, get it thoroughly fragmented, then 
push it reasonably hard constant pressure, and try allocating anything
large. 

Seems to me we're basically pointing a blunderbuss at memory, and 
blowing away large portions, and *hoping* something falls out the
bottom that's a big enough chunk?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
