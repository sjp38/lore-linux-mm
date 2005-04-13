Message-ID: <425C7708.2090805@yahoo.com.au>
Date: Wed, 13 Apr 2005 11:34:00 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/4] pcp: zonequeues
References: <4257D74C.3010703@yahoo.com.au> <20050412161523.GA7466@sgi.com>
In-Reply-To: <20050412161523.GA7466@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Jack Steiner wrote:
> On Sat, Apr 09, 2005 at 11:23:24PM +1000, Nick Piggin wrote:

>>Comments?
>>
> 
> 
> Nick
> 
> I tested the patch. I found one spot that was missed  with the NUMA 
> statistics but everything else looks fine. The patches fix both problems
> that I found - bad coloring & excessive pages in pagesets.
> 

Thanks. I'll think about how to make them more acceptable
for merging.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
