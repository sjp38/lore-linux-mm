Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA08614
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 11:11:10 -0500
Date: Tue, 12 Jan 1999 16:10:42 GMT
Message-Id: <199901121610.QAA04831@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: question about try_to_swap_out()
In-Reply-To: <199901110338.VAA19737@feta.cs.utexas.edu>
References: <199901110338.VAA19737@feta.cs.utexas.edu>
Sender: owner-linux-mm@kvack.org
To: "Paul R. Wilson" <wilson@cs.utexas.edu>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 10 Jan 1999 21:38:46 -0600, "Paul R. Wilson"
<wilson@cs.utexas.edu> said:

> After checking that that a page is present and pageable, try_to_swap_out()
> checks to see if the page is reserved or locked or not DMA'able when
> where looking for a DMA page.  If any of these three things is
> true, it returns 0 without changing anything.

> It seems to me that it should go ahead and check the pte age bit,
> and update the page frame's PG_referenced bit, before returning 0.

Not really.  Reserved pages never get swapped anyway.  For DMA, we don't
want to disturb non-DMA processes at all --- the demand for DMA and
non-DMA pages might be very different.  For locked pages, we expect this
to be sufficiently rare that it's totally irrelevant whether we age the
page or not.

> Am I off-base here, or should the conditional that checks to see
> whether a page is young (and updates the reference bits) be moved
> up ahead of the conditional that checks to see whether a page
> is (reserved | locked | not-dma-but-we-need-dma)?

I really don't think it's that important!

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
