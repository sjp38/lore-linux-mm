Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA29378
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 17:19:41 -0500
Date: Wed, 25 Nov 1998 22:19:19 GMT
Message-Id: <199811252219.WAA05712@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: rw_swap_page() and swapin readahead
In-Reply-To: <Pine.LNX.3.96.981125225829.15920C-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.96.981125225829.15920C-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 25 Nov 1998 23:02:30 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> Hi Stephen,
> it appears that rw_swap_page() needs a small change to be
> able to do asynchonous swapin.

> On line 128:
> 		if (!wait) {
> 			set_bit(PG_free_after, &page->flags);
> 			...
> 		}

No, that's fine as it is: one of the things rw_swap_page does early on
is to increment the page's count, so that even if the caller frees the
page before the IO is complete, nobody else tries to reuse it while the
IO is still outstanding.  The PG_free_after bit is there only to mark
that increment, so that the page count is decremented again
(asynchronously) once the IO is complete and no sooner.

> If I misunderstood the code, I'll happily learn a bit :)

You're welcome. :)

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
