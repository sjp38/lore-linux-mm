Received: from newsguy.com (thparkth@localhost [127.0.0.1])
	by newsguy.com (8.12.9/8.12.8) with ESMTP id i4CIOlsG063753
	for <linux-mm@kvack.org>; Wed, 12 May 2004 11:24:47 -0700 (PDT)
	(envelope-from thparkth@newsguy.com)
Received: (from thparkth@localhost)
	by newsguy.com (8.12.9/8.12.8/Submit) id i4CIOl64063750
	for linux-mm@kvack.org; Wed, 12 May 2004 11:24:47 -0700 (PDT)
	(envelope-from thparkth)
Date: Wed, 12 May 2004 11:24:47 -0700 (PDT)
Message-Id: <200405121824.i4CIOl64063750@newsguy.com>
From: Andrew Crawford <acrawford@ieee.org>
Subject: Re: The long, long life of an inactive_dirty page
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks for all your replies so far, and the helpful information.

> well you may IF you fix  your mail setup to not send me evil mails about
> having to confirm something.

Just to clarify, you received that mail because you replied to this address
directly; This account don't accept emails from unverified addresses. This
account is not subscribed to linux-mm, which I read elsewhere.

> One thing to realize is that after bdflush has written the pages out, they
> can become dirty AGAIN for a variety of reasons, and as such the accounting
> is not quite straightforward.

Is it possible for a page to become dirty again while still remaining
inactive? Could you give an example? (genuinely curious, hope this doesn't
sound like I'm arguing!)

> the problem is that the "becoming clean" is basically asynchronous

Isn't this equally true for page_launder? Even if bdflush would wait until the
next "pass" to move pages to the "clean" list it would be better than the
current situation. There must be some mechanism that bdflush uses to avoid
writing the same page twice in a row; couldn't it say "oh, already wrote that
one, into inactive_clean it goes".

You will probably appreciate that I am coming at this from the point of view
of performance measurement and capacity planning; I want to know how much
actual memory is free or immediately reusable at a point in time.

With thanks for all help,

 Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
