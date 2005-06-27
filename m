Message-ID: <42BFC10E.50204@yahoo.com.au>
Date: Mon, 27 Jun 2005 19:04:14 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc] lockless pagecache
References: <42BF9CD1.2030102@yahoo.com.au> <20050627004624.53f0415e.akpm@osdl.org> <42BFB287.5060104@yahoo.com.au> <42BFBF5B.7080301@cisco.com>
In-Reply-To: <42BFBF5B.7080301@cisco.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lincoln Dale <ltd@cisco.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Lincoln Dale wrote:
> Nick Piggin wrote:
> [..]
> 
>> However I think for Oracle and others that use shared memory like
>> this, they are probably not doing linear access, so that would be a
>> net loss. I'm not completely sure (I don't have access to real loads
>> at the moment), but I would have thought those guys would have looked
>> into fault ahead if it were a possibility.
> 
> 
> i thought those guys used O_DIRECT - in which case, wouldn't the page 
> cache not be used?
> 

Well I think they do use O_DIRECT for their IO, but they need to
use the Linux pagecache for their shared memory - that shared
memory being the basis for their page cache. I think. Whatever
the setup I believe they have issues with the tree_lock, which is
why it was changed to an rwlock.

-- 
SUSE Labs, Novell Inc.


Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
