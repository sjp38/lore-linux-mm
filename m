From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14453.54081.644647.363133@dukat.scot.redhat.com>
Date: Fri, 7 Jan 2000 11:51:29 +0000 (GMT)
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <38750A00.A4EE572A@idiom.com>
References: <Pine.LNX.4.10.10001061910180.1936-100000@alpha.random>
	<38750A00.A4EE572A@idiom.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <reiser@idiom.com>
Cc: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, Chris Mason <mason@suse.com>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 07 Jan 2000 00:32:48 +0300, Hans Reiser <reiser@idiom.com> said:

> Andrea Arcangeli wrote:
>> BTW, I thought Hans was talking about places that can't sleep (because of
>> some not schedule-aware lock) when he said "place that cannot call
>> balance_dirty()".

> You were correct.  I think Stephen and I are missing in communicating here.

Fine, I was just looking at it from the VFS point of view, not the
specific filesystem.  In the worst case, a filesystem can always simply
defer marking the buffer as dirty until after the locking window has
passed, so there's obviously no fundamental problem with having a
blocking mark_buffer_dirty.  If we want a non-blocking version too, with
the requirement that the filesystem then to a manual rebalance once it
is safe to do so, that will work fine too.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
