Received: from newsguy.com (thparkth@localhost [127.0.0.1])
	by newsguy.com (8.12.9/8.12.8) with ESMTP id i4CJIusG095495
	for <linux-mm@kvack.org>; Wed, 12 May 2004 12:18:59 -0700 (PDT)
	(envelope-from thparkth@newsguy.com)
Received: (from thparkth@localhost)
	by newsguy.com (8.12.9/8.12.8/Submit) id i4CJIlF6095429
	for linux-mm@kvack.org; Wed, 12 May 2004 12:18:47 -0700 (PDT)
	(envelope-from thparkth)
Date: Wed, 12 May 2004 12:18:47 -0700 (PDT)
Message-Id: <200405121918.i4CJIlF6095429@newsguy.com>
From: Andrew Crawford <acrawford@ieee.org>
Subject: Re: The long, long life of an inactive_dirty page
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> That information is not achievable in a reliable way, ever. Simply because
> it takes a not-even-near-inifintely small amount of time to gather all the
> stats, during which the other cpu can change all the underlying data away
> under your nose.

Although that is of course true, it's also well understood and a factor with
any operating system. Nevertheless, it would be useful to have a picture of
how much memory is available right now. An inaccurate (within reason)
indication *would* be better than none at all.

Just to gather opinions, and since we've been having a bit of a heated
discussion about it here at work, how would you good people define "available
RAM"? and which memory metrics would make it up?

My definition would be "RAM which can be allocated and used without the need
to write any pages". I.e if the memory needs laundered first but no actual
writes need to be done, that's fine and I'll count it as available.

So I'd be counting

  Free
  +
  Inactive_Clean
  +
  The clean part of inactive_dirty (which can't be measured at present)

Is there anything else that should be on there?

Cheers,

Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
