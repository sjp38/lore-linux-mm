Date: Fri, 21 Sep 2001 22:14:29 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: broken VM in 2.4.10-pre9
In-Reply-To: <m1wv2t7y18.fsf@frodo.biederman.org>
Message-ID: <Pine.GSO.4.21.0109212151590.9760-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Daniel Phillips <phillips@bonn-fries.net>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 21 Sep 2001, Eric W. Biederman wrote:

> Swapping is an important case.  But 9 times out of 10 you are managing
> memory in caches, and throwing unused pages into swap.  You aren't busily
> paging the data back an forth.  But if I have to make a choice in
> what kind of situation I want to take a performance hit, paging
> approaching thrashing or a system whose working set size is well
> within RAM.  I'd rather take the hit in the system that is paging.

It means that you prefer system dying under much lighter load.  At some
point any box will get into feedback loop, when slowdown from VM load
will make request handling slower, which will make temp. allocations
needed to handle these requests to be kept around for longer periods,
which will contribute to VM load.  The question being, at which point
will it happen and how graceful will the degradation be when we get
near that point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
