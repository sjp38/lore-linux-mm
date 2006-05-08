Message-ID: <445ED495.3020401@yahoo.com.au>
Date: Mon, 08 May 2006 15:18:13 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] fix can_share_swap_page() when !CONFIG_SWAP
References: <Pine.LNX.4.64.0605071525550.2515@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.64.0605071525550.2515@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hua Zhong <hzhong@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hua Zhong wrote:

>Hi,
>
>can_share_swap_page() is used to check if the page has the last reference. This avoids allocating a new page for COW if it's the last page.
>
>However, if CONFIG_SWAP is not set, can_share_swap_page() is defined as 0, thus always causes a copy for the last COW page. The below simple patch fixes it.
>
>I'm not sure if it's the best fix. Maybe we should rename can_share_swap_page() and move it out of swapfile.c. Comments?
>

Looks like a good patch, nice catch. You should run it past Hugh but tend to
agree it would be nice to reuse the out of line can_share_swap_page, 
which would
fold beautifully with PageSwapCache a constant 0.

Nick
--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
