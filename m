Message-ID: <42C09AB3.7030907@yahoo.com.au>
Date: Tue, 28 Jun 2005 10:32:51 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc] lockless pagecache
References: <42BF9CD1.2030102@yahoo.com.au> <20050627004624.53f0415e.akpm@osdl.org> <42BFB287.5060104@yahoo.com.au> <20050627131710.GC13945@kvack.org>
In-Reply-To: <20050627131710.GC13945@kvack.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:
> On Mon, Jun 27, 2005 at 06:02:15PM +1000, Nick Piggin wrote:
> 
>>However I think for Oracle and others that use shared memory like
>>this, they are probably not doing linear access, so that would be a
>>net loss. I'm not completely sure (I don't have access to real loads
>>at the moment), but I would have thought those guys would have looked
>>into fault ahead if it were a possibility.
> 
> 
> Shared memory overhead doesn't show up on any of the database benchmarks 
> I've seen, as they tend to use huge pages that are locked in memory, and 
> thus don't tend to access the page cache at all after ramp up.
> 

To be quite honest I don't have any real workloads here that stress
it, however I was told that it is a problem for oracle database. If
there is anyone else who has problems then I'd be interested to hear
them as well.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
