Date: Sat, 02 Oct 2004 12:50:55 +0900 (JST)
Message-Id: <20041002.125055.74752207.taka@valinux.co.jp>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <415E154A.2040209@cyberone.com.au>
References: <20041001182221.GA3191@logos.cnet>
	<415E154A.2040209@cyberone.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: piggin@cyberone.com.au
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org, akpm@osdl.org, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

> >For example it doesnt re establishes pte's once it has unmapped them.
> >
> >
> 
> Another thing - I don't know if I'd bother re-establishing ptes....
> I'd say just leave it to happen lazily at fault time.

I think the reason is that his current implementation doesn't assign
a swap entry to an anonymous page to move.


Thank you,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
