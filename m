Message-ID: <42BFB8BE.20903@yahoo.com.au>
Date: Mon, 27 Jun 2005 18:28:46 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc] lockless pagecache
References: <42BF9CD1.2030102@yahoo.com.au>	<20050627004624.53f0415e.akpm@osdl.org>	<42BFB287.5060104@yahoo.com.au> <20050627011539.28793896.akpm@osdl.org>
In-Reply-To: <20050627011539.28793896.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>Also, the memory usage regression cases that fault ahead brings makes it
>> a bit contentious.
> 
> 
> faultahead consumes no more memory: if the page is present then point a pte
> at it.  It'll make reclaim work a bit harder in some situations.
> 

Oh OK we'll call that faultahead and Christoph's thing prefault then.

I suspect it may still be a net loss for those that are running into
tree_lock contention, but we'll see.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
