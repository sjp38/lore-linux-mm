Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA09651
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 13:15:25 -0500
Date: Tue, 12 Jan 1999 18:14:49 GMT
Message-Id: <199901121814.SAA11098@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: question about try_to_swap_out()
In-Reply-To: <199901121658.KAA28147@feta.cs.utexas.edu>
References: <199901121658.KAA28147@feta.cs.utexas.edu>
Sender: owner-linux-mm@kvack.org
To: "Paul R. Wilson" <wilson@cs.utexas.edu>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 12 Jan 1999 10:58:52 -0600, "Paul R. Wilson"
<wilson@cs.utexas.edu> said:

> I would think that it could be significant if you're skipping DMA
> pages, which are valuable.  You want to get them back in a timely
> manner, so you want to go ahead and age them normally.

We don't ever do that.  We can _require_ a DMA allocation, but we never
explicitly avoid allocating DMA pages.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
