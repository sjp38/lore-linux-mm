Message-ID: <4450C8C6.9040309@yahoo.com.au>
Date: Thu, 27 Apr 2006 23:36:06 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Lockless page cache test results
References: <20060426135310.GB5083@suse.de> <20060426095511.0cc7a3f9.akpm@osdl.org> <20060426174235.GC5002@suse.de> <20060426111054.2b4f1736.akpm@osdl.org> <Pine.LNX.4.64.0604261144290.3701@g5.osdl.org> <20060426191557.GA9211@suse.de> <20060426131200.516cbabc.akpm@osdl.org> <20060427074533.GJ9211@suse.de> <4450796A.2030908@yahoo.com.au> <44507AA9.2010005@yahoo.com.au> <20060427090000.GA23137@suse.de>
In-Reply-To: <20060427090000.GA23137@suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jens Axboe wrote:
> On Thu, Apr 27 2006, Nick Piggin wrote:

>>Hmm, what's more, find_get_pages_contig shouldn't result in any
>>fewer tree_lock acquires than the open coded thing there now
>>(for the densely populated pagecache case).
> 
> 
> How do you figure? The open coded one does a find_get_page() on each
> page in that range, so for x number of pages we'll grab and release
> ->tree_lock x times.

Yeah you're right. I had in mind that you were using
find_get_pages_contig in readahead, rather than in splice.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
