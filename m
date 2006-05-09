Date: Tue, 9 May 2006 12:25:43 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] fix can_share_swap_page() when !CONFIG_SWAP
In-Reply-To: <445FF78B.9060803@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0605091223190.19410@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0605071525550.2515@localhost.localdomain>
 <445ED495.3020401@yahoo.com.au> <Pine.LNX.4.64.0605081335030.7003@blonde.wat.veritas.com>
 <445FF78B.9060803@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hua Zhong <hzhong@gmail.com>, linux-kernel@vger.kernel.org, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 May 2006, Nick Piggin wrote:
> Hugh Dickins wrote:
> >
> >True; but I think Hua's patch is good as is for now, to fix
> >that inefficiency.  I do agree (as you know) that there's scope for
> >cleanup there, and that that function is badly named; but I'm still
> >unprepared to embark on the cleanup, so let's just get the fix in.
> 
> Sure. Queue it up for 2.6.18?

I'd be perfectly happy for Hua's one-liner to go into 2.6.17;
but that's up to Andrew.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
