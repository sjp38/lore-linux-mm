Date: Thu, 6 Jan 2000 19:20:40 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <14452.54644.697386.175701@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.10001061910180.1936-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Hans Reiser <reiser@idiom.com>, Chris Mason <mason@suse.com>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

BTW, I thought Hans was talking about places that can't sleep (because of
some not schedule-aware lock) when he said "place that cannot call
balance_dirty()".

On Thu, 6 Jan 2000, Stephen C. Tweedie wrote:

>It shouldn't be impossible: as long as we are protected against
>recursive invocations of balance_dirty (which should be easy to

I am not sure to understand correctly. In case the ll_rw_block layer
produces dirty buffers we are protected by wakeup_bdflush that become a
noop when recalled from kflushd (wakeup_bdflush is not blocking to avoid
bdflush waiting bdflush :). And in genral balance_dirty should never
recurse on the same stack.

>arrange) we should be safe enough, at least if the memory reservation
>bits of the VM/fs interaction are working so that the balance_dirty
>can guarantee to run to completion.

Hmm maybe you are talking about something else...

Andrea


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
