Message-ID: <42781AC5.1000201@yahoo.com.au>
Date: Wed, 04 May 2005 10:43:49 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] how do we move the VM forward? (was Re: [RFC] cleanup of
 use-once)
References: <Pine.LNX.4.61.0505030037100.27756@chimarrao.boston.redhat.com> <42771904.7020404@yahoo.com.au> <Pine.LNX.4.61.0505030913480.27756@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.61.0505030913480.27756@chimarrao.boston.redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Tue, 3 May 2005, Nick Piggin wrote:
> 
>> I think the biggest problem with our twine and duct tape page reclaim
>> scheme is that somehow *works* (for some value of works).
> 
> 
>> I think we branch a new tree for all interested VM developers to work
>> on and try to get performing well. Probably try to restrict it to page
>> reclaim and related fundamentals so it stays as small as possible and
>> worth testing.
> 
> 
> Sounds great.  I'd be willing to maintain a quilt tree for
> this - in fact, I've already got a few patches ;)
> 

OK I'll help maintain and review patches.

Also having a box or two for running regression and stress
testing is a must. I can do a bit here, but unfortunately
"kernel compiles until it hurts" is probably not the best
workload to target.

In general most systems and their workloads aren't constantly
swapping, so we should aim to minimise IO for normal
workloads. Databases that use the pagecache (eg. postgresql)
would be a good test. But again we don't want to focus on one
thing.

That said, of course we don't want to hurt the "really
thrashing" case - and hopefully improve it if possible.

> Also, we should probably keep track of exactly what we're
> working towards.  I've put my ideas on a wiki page, feel
> free to add yours - probably a new page for stuff that's
> not page replacement related ;)
> 

I guess some of those page replacement algorithms would be
really interesting to explore - and we definitely should be
looking into them at some stage as part of our -vm tree.

Though my initial aims are to first simplify and rationalise
and unify things where possible.

NUMA "issues" related to page reclaim are also interesting to
me.

I'll try to get some time to get my patches into shape in the
next week or so.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
