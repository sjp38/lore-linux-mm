Message-ID: <48F886B9.8030403@davidnewall.com>
Date: Fri, 17 Oct 2008 23:06:09 +1030
From: David Newall <davidn@davidnewall.com>
MIME-Version: 1.0
Subject: Re: no way to swapoff a deleted swap file?
References: <bnlDw-5vQ-7@gated-at.bofh.it> <bnwpg-2EA-17@gated-at.bofh.it> <bnJFK-3bu-7@gated-at.bofh.it> <bnR0A-4kq-1@gated-at.bofh.it> <E1KqkZK-0001HO-WF@be1.7eggert.dyndns.org> <Pine.LNX.4.64.0810171250410.22374@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0810171250410.22374@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Bodo Eggert <7eggert@gmx.de>, Peter Zijlstra <peterz@infradead.org>, Peter Cordes <peter@cordes.ca>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Fri, 17 Oct 2008, Bodo Eggert wrote:
>   
>> Somebody might want their swapfiles to have zero links,
>> _and_ the possibility of doing swapoff.
>>     
>
> You're right, they might, and it's not an unreasonable wish.
> But we've not supported it in the past, and I still don't
> think it's worth adding special kernel support for it now.

But it is supported now.  It's swapoff that's not supported, and I don't
think that matters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
