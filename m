Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA32360
	for <linux-mm@kvack.org>; Wed, 2 Dec 1998 12:34:40 -0500
Date: Wed, 2 Dec 1998 17:33:32 GMT
Message-Id: <199812021733.RAA04470@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] swapin readahead
In-Reply-To: <87vhjvkccu.fsf@atlas.CARNet.hr>
References: <Pine.LNX.3.96.981201173030.2458A-100000@mirkwood.dummy.home>
	<87vhjvkccu.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 01 Dec 1998 18:20:49 +0100, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

> Yes. something like that. Since nobody asked pages to swap in (we
> decided to swap them in) it looks like nobody frees them. :)
> So we should free them somewhere, probably.

I think read_swap_page_async should be acting as a lookup on the page
cache, so the page it returns is guaranteed to have an incremented
reference count.  You'll need to free_page() it just after the
read_swap_page_async() call to get the expected behaviour.

You still need to skip locked swap entries, too.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
