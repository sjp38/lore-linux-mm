Message-ID: <447BEB2F.7020605@yahoo.com.au>
Date: Tue, 30 May 2006 16:50:23 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447AC011.8050708@yahoo.com.au> <20060530055115.GD18626@filer.fsl.cs.sunysb.edu> <447BE9E9.4000907@yahoo.com.au>
In-Reply-To: <447BE9E9.4000907@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Chris Mason <mason@suse.com>, Andrea Arcangeli <andrea@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Jens Axboe <axboe@suse.de>, Linus Torvalds <torvalds@osdl.org>, mike@halcrow.us, ezk@cs.sunysb.edu
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Josef Sipek wrote:
> 
>> On Mon, May 29, 2006 at 07:34:09PM +1000, Nick Piggin wrote:
>> ...
>>
>>> Can we get rid of the whole thing, confusing memory barriers and all?
>>> Nobody uses anything but the default sync_page
>>
>>
>>
>> I feel like I must say this: there are some file systems that live
>> outside the kernel (at least for now) that do _NOT_ use the default
>> sync_page. All the stackable file systems that are based on FiST [1],
>> such as Unionfs [2] and eCryptfs (currently in -mm) [3] (respective
>> authors CC'd). As an example, Unionfs must decide which lower file
>> system page to sync (since it may have several to chose from).
> 
> 
> OK, noted. Thanks. Luckily for them it looks like sync_page might
> stay for other reasons (eg. raid) ;)

Ah, no: that's the backing dev's unplug_fn. sync_page is always the
same. And it has definite bugs now that splice has been merged.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
