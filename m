Message-ID: <45B7561C.9000102@yahoo.com.au>
Date: Wed, 24 Jan 2007 23:50:36 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Limit the size of the pagecache
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com> <1169625333.4493.16.camel@taijtu>
In-Reply-To: <1169625333.4493.16.camel@taijtu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Aubrey Li <aubreylee@gmail.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Tue, 2007-01-23 at 16:49 -0800, Christoph Lameter wrote:

>>2. Insure rapid turnaround of pages in the cache.

[...]

> The  only maybe valid point would be 2, and I'd like to see if we can't
> solve that differently - a better use-once logic comes to mind.

There must be something I'm missing with that point. The faster
the turnaround of pagecache pages, the *less* efficiently the
pagecache is working (assuming a rapid turnaround means a high
rate of pages brought into, then reclaimed from pagecache).

I can't argue that a smaller pagecache will be subject to a
higher turnaround given the same workload, but I don't know why
that would be a good thing.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
