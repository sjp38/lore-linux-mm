Message-ID: <387645AD.CDE9B054@idiom.com>
Date: Fri, 07 Jan 2000 22:59:41 +0300
From: Hans Reiser <reiser@idiom.com>
MIME-Version: 1.0
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
References: <Pine.LNX.4.10.10001061910180.1936-100000@alpha.random>
		<38750A00.A4EE572A@idiom.com> <14453.54081.644647.363133@dukat.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Chris Mason <mason@suse.com>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:

> Hi,
>
> On Fri, 07 Jan 2000 00:32:48 +0300, Hans Reiser <reiser@idiom.com> said:
>
> > Andrea Arcangeli wrote:
> >> BTW, I thought Hans was talking about places that can't sleep (because of
> >> some not schedule-aware lock) when he said "place that cannot call
> >> balance_dirty()".
>
> > You were correct.  I think Stephen and I are missing in communicating here.
>
> Fine, I was just looking at it from the VFS point of view, not the
> specific filesystem.  In the worst case, a filesystem can always simply
> defer marking the buffer as dirty until after the locking window has
> passed, so there's obviously no fundamental problem with having a
> blocking mark_buffer_dirty.  If we want a non-blocking version too, with
> the requirement that the filesystem then to a manual rebalance once it
> is safe to do so, that will work fine too.
>
> --Stephen

Yes, but then you have to track what you defer.  Code complication.

I just want to leave things as they are until we have time to do SMP right.

When we do SMP right, then a mark_buffer_dirty() which causes schedule is not a
problem.  Let's deal with this in 2.5....

Hans

--
Get Linux (http://www.kernel.org) plus ReiserFS
 (http://devlinux.org/namesys).  If you sell an OS or
internet appliance, buy a port of ReiserFS!  If you
need customizations and industrial grade support, we sell them.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
