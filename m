Message-ID: <45B6CBD9.80600@yahoo.com.au>
Date: Wed, 24 Jan 2007 14:00:41 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Limit the size of the pagecache
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Aubrey Li <aubreylee@gmail.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> This is a patch using some of Aubrey's work plugging it in what is IMHO 
> the right way. Feel free to improve on it. I have gotten repeatedly 
> requests to be able to limit the pagecache. With the revised VM statistics 
> this is now actually possile. I'd like to know more about possible uses of 
> such a feature.
> 
> 
> 
> 
> It may be useful to limit the size of the page cache for various reasons
> such as
> 
> 1. Insure that anonymous pages that may contain performance
>    critical data is never subject to swap.
> 
> 2. Insure rapid turnaround of pages in the cache.

So if these two aren't working properly at 100%, then I want to know the
reason why. Or at least see what the workload and the numbers look like.

> 
> 3. Reserve memory for other uses? (Aubrey?)

Maybe. This is still a bad hack, and I don't like to legitimise such use
though. I hope Aubrey isn't relying on this alone for his device to work
because his customers might end up hitting fragmentation problems sooner
or later.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
