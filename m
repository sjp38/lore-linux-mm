Message-ID: <38750A00.A4EE572A@idiom.com>
Date: Fri, 07 Jan 2000 00:32:48 +0300
From: Hans Reiser <reiser@idiom.com>
MIME-Version: 1.0
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
References: <Pine.LNX.4.10.10001061910180.1936-100000@alpha.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Chris Mason <mason@suse.com>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> BTW, I thought Hans was talking about places that can't sleep (because of
> some not schedule-aware lock) when he said "place that cannot call
> balance_dirty()".

You were correct.  I think Stephen and I are missing in communicating here.


--
Get Linux (http://www.kernel.org) plus ReiserFS
 (http://devlinux.org/namesys).  If you sell an OS or
internet appliance, buy a port of ReiserFS!  If you
need customizations and industrial grade support, we sell them.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
