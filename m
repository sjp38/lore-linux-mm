Date: Tue, 7 Jul 1998 13:32:34 -0400 (8UU)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980707175139.18757A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980707125719.613B-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Jul 1998, Rik van Riel wrote:

> There's a good compromize between balancing per-page
> and per-process. We can simply declare the last X
> (say 8) pages of a process holy unless that process
> has slept for more than Y (say 5) seconds.

This is the wrong fix for the case that Andrea is complaining about -
tossing out chunks of processes piecemeal, resulting in a length page-in
time when the process becomes active again.  Two things that might help
with this are: read-ahead on swapins, and *true* swapping.  If the system
has run out of ram for the tasks at hand, should it not swap out a process
that's inactive in one fell swoop?  Likewise, when said process resumes,
it's probably worth bringing that entire working set back into memory.
That way the user will only experience a brief pause on the first
keystroke issued to bash, not the 'pause on first character type, then
pause as line editing code faults back in...'

		-ben


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
