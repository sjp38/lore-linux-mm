Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA09756
	for <linux-mm@kvack.org>; Tue, 17 Nov 1998 06:21:37 -0500
Date: Tue, 17 Nov 1998 11:21:22 GMT
Message-Id: <199811171121.LAA00897@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: useless report -- perhaps memory allocation problems in 2.1.12[678]
In-Reply-To: <Pine.LNX.3.96.981116152322.20349E-100000@mirkwood.dummy.home>
References: <199811131746.LAA23512@mail.mankato.msus.edu>
	<Pine.LNX.3.96.981116152322.20349E-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Jeffrey Hundstad <jeffrey.hundstad@mankato.msus.edu>, Linux MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

In article
<Pine.LNX.3.96.981116152322.20349E-100000@mirkwood.dummy.home>, Rik van
Riel <H.H.vanRiel@phys.uu.nl> writes:

> In 2.1.127+ the freeing of memory is done in the context of
> programs themselves too 

It always has done: it's just a bit better at it in some situations now.

> and the whole system is busy freeing memory. This means that the
> kswapd-loop has now been migrated into other contexts as well. This,
> together with the fact that kswapd never blocks on disk access any
> more,

Yes it does.  We don't pass GFP_WAIT to swap_out(), but that just means
that the swapout will be done asynchronously.  We are still free to
write stuff out to swap, and in fact once we hit the limit on
outstanding IOs we may well block in the write.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
