Message-ID: <445FF78B.9060803@yahoo.com.au>
Date: Tue, 09 May 2006 11:59:39 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] fix can_share_swap_page() when !CONFIG_SWAP
References: <Pine.LNX.4.64.0605071525550.2515@localhost.localdomain> <445ED495.3020401@yahoo.com.au> <Pine.LNX.4.64.0605081335030.7003@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0605081335030.7003@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Hua Zhong <hzhong@gmail.com>, linux-kernel@vger.kernel.org, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:

>On Mon, 8 May 2006, Nick Piggin wrote:
>
>>Looks like a good patch, nice catch. You should run it past Hugh but tend to
>>agree it would be nice to reuse the out of line can_share_swap_page, which
>>would fold beautifully with PageSwapCache a constant 0.
>>
>
>True; but I think Hua's patch is good as is for now, to fix
>that inefficiency.  I do agree (as you know) that there's scope for
>cleanup there, and that that function is badly named; but I'm still
>unprepared to embark on the cleanup, so let's just get the fix in.
>

Sure. Queue it up for 2.6.18?
--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
