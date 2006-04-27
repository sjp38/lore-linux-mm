Message-ID: <44507AA9.2010005@yahoo.com.au>
Date: Thu, 27 Apr 2006 18:02:49 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Lockless page cache test results
References: <20060426135310.GB5083@suse.de> <20060426095511.0cc7a3f9.akpm@osdl.org> <20060426174235.GC5002@suse.de> <20060426111054.2b4f1736.akpm@osdl.org> <Pine.LNX.4.64.0604261144290.3701@g5.osdl.org> <20060426191557.GA9211@suse.de> <20060426131200.516cbabc.akpm@osdl.org> <20060427074533.GJ9211@suse.de> <4450796A.2030908@yahoo.com.au>
In-Reply-To: <4450796A.2030908@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Jens Axboe wrote:
> 
>> Things look pretty bad for the lockless kernel though, Nick any idea
>> what is going on there? The splice change is pretty simple, see the top
>> three patches here:
> 
> 
> Could just be the use of spin lock instead of read lock.
> 
> I don't think it would be hard to convert find_get_pages_contig
> to be lockless.
> 
> Patched vanilla numbers look nicer, but I'm curious as to why
> __do_page_cache was so bad before, if the file was in cache.
> Presumably it should not more than double tree_lock acquisition...
> it isn't getting called multiple times for each page, is it?

Hmm, what's more, find_get_pages_contig shouldn't result in any
fewer tree_lock acquires than the open coded thing there now
(for the densely populated pagecache case).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
