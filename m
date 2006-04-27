Message-ID: <44505D75.8070409@yahoo.com.au>
Date: Thu, 27 Apr 2006 15:58:13 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Lockless page cache test results
References: <20060426135310.GB5083@suse.de>	<20060426095511.0cc7a3f9.akpm@osdl.org>	<20060426174235.GC5002@suse.de>	<20060426111054.2b4f1736.akpm@osdl.org>	<20060426182323.GI5002@suse.de> <20060426114649.5a0e0dea.akpm@osdl.org>
In-Reply-To: <20060426114649.5a0e0dea.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Jens Axboe <axboe@suse.de>, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Jens Axboe <axboe@suse.de> wrote:
> 
>>Are there cases where the lockless page cache performs worse than the
>>current one?
> 
> 
> Yeah - when human beings try to understand and maintain it.

Have any tried yet? ;)

I won't deny it is complex (because I don't like when I make the
same point and people go on to take great trouble to convince me
how simple it is!).

But I hope it isn't _too_ bad. It is basically a dozen line
function at the core, and that gets used to implement
find_get_page, find_lock_page. Their semantics remain the same,
so that's where the line is drawn (plus minor things, like an
addition for reclaim's remove-from-pagecache protocol).

IMO the rcu radix tree is probably the most complex bit... but
that pales in comparison to things like our prio tree, or RCU
trie.

> 
> The usual tradeoffs apply ;)

Definitely. It isn't fun if you just take the patch and merge it.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
