Message-ID: <4450551D.5050000@yahoo.com.au>
Date: Thu, 27 Apr 2006 15:22:37 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Lockless page cache test results
References: <20060426135310.GB5083@suse.de>	<20060426095511.0cc7a3f9.akpm@osdl.org>	<20060426174235.GC5002@suse.de> <20060426111054.2b4f1736.akpm@osdl.org>
In-Reply-To: <20060426111054.2b4f1736.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Jens Axboe <axboe@suse.de>, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>>The top of the 4-client
>>vanilla run profile looks like this:
>>
>>samples  %        symbol name
>>65328    47.8972  find_get_page
>>
>>Basically the machine is fully pegged, about 7% idle time.
> 
> 
> Most of the time an acquisition of tree_lock is associated with a disk
> read, or a page-size memset, or a page-size memcpy.  And often an
> acquisition of tree_lock is associated with multiple pages, not just a
> single page.

Still, most of the times it is acquired would be once per page for
read, write, nopage.

For read and write, often it will be a full page memcpy but even such
a memcpy operation can quickly become insignificant compared to tl
contention.

Anyway, whatever. What needs to be demonstrated are real world
improvements at the end of the day.

> 
> So although the graph looks good, I wouldn't view this as a super-strong
> argument in favour of lockless pagecache.

No. Cool numbers though ;)

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
