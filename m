Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA23855
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 16:49:27 -0500
Date: Sun, 10 Jan 1999 21:49:07 GMT
Message-Id: <199901102149.VAA01490@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: tiny patch, reduces kernel memory usage (memory_save patch)
In-Reply-To: <Pine.LNX.3.96.990110174423.15469A-100000@Linuz.sns.it>
References: <Pine.LNX.3.96.990110174423.15469A-100000@Linuz.sns.it>
Sender: owner-linux-mm@kvack.org
To: Max <max@Linuz.sns.it>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@e-mind.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 10 Jan 1999 18:00:52 +0100 (MET), Max <max@Linuz.sns.it> said:

> I am really sorry to disturb with something that is supposed to be discussed
> in linux-kernel, but looks linux-kernel is terribly lagged, and also my
> original message (sent on Jan 7) got somehow ignored.

> -	unsigned int unused;
> -	unsigned long map_nr;	/* page->map_nr == page - mem_map */

The unused field needs to go.  Fine.  The map_nr field is needed to
avoid a division when we try to find a page number from a struct page.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
