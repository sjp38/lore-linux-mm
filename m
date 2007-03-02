Message-ID: <45E87D93.9000100@redhat.com>
Date: Fri, 02 Mar 2007 14:40:03 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <45E842F6.5010105@redhat.com> <20070302085838.bcf9099e.akpm@linux-foundation.org> <Pine.LNX.4.64.0703020919350.16719@schroedinger.engr.sgi.com> <20070302093501.34c6ef2a.akpm@linux-foundation.org> <45E8624E.2080001@redhat.com> <20070302100619.cec06d6a.akpm@linux-foundation.org> <Pine.LNX.4.64.0703021012170.17676@schroedinger.engr.sgi.com> <45E86BA0.50508@redhat.com> <Pine.LNX.4.64.0703021126470.17883@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0703021126470.17883@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 2 Mar 2007, Rik van Riel wrote:
> 
>> I would like to see separate pageout selection queues
>> for anonymous/tmpfs and page cache backed pages.  That
>> way we can simply scan only that what we want to scan.
>>
>> There are several ways available to balance pressure
>> between both sets of lists.
>>
>> Splitting them out will also make it possible to do
>> proper use-once replacement for the page cache pages.
>> Ie. leaving the really active page cache pages on the
>> page cache active list, instead of deactivating them
>> because they're lower priority than anonymous pages.
> 
> Well I would expect this to have marginal improvements and delay the 
> inevitable for awhile until we have even bigger memory. If the app uses 
> mmapped data areas then the problem is still there.

I suspect we would not need to treat mapped file backed memory any
different from page cache that's not mapped.  After all, if we do
proper use-once accounting, the working set will be on the active
list and other cache will be flushed out the inactive list quickly.

Also, the IO cost for mmapped data areas is the same as the IO
cost for unmapped files, so there's no IO reason to treat them
differently, either.


-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
