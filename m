Message-ID: <45975274.6020909@yahoo.com.au>
Date: Sun, 31 Dec 2006 17:02:28 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Page alignment issue
References: <6d6a94c50612270749j77cd53a9mba6280e4129d9d5a@mail.gmail.com>
In-Reply-To: <6d6a94c50612270749j77cd53a9mba6280e4129d9d5a@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey <aubreylee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Aubrey wrote:
> As for the buddy system, much of docs mention the physical address of
> the first page frame of a block should be a multiple of the group
> size. For example, the initial address of a 16-page-frame block should
> be 16-page aligned. I happened to encounted an issue that the physical
> addresss pf the block is not 4-page aligned(0x36c9000) while the order
> of the block is 2. I want to know what out of buddy algorithm depend
> on this feature?

I think that's correct. The buddy allocator uses bitwise operations to
find buddy pages and promote free pairs (eg. see __page_find_buddy()
and __find_combined_index()).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
