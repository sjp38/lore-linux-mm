Message-ID: <38620F5A.F4E6301A@idiom.com>
Date: Thu, 23 Dec 1999 15:02:34 +0300
From: Hans Reiser <reiser@idiom.com>
MIME-Version: 1.0
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
References: <Pine.LNX.3.96.991221200955.16115B-100000@kanga.kvack.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

"Benjamin C.R. LaHaise" wrote:

> I completly agree to change mark_buffer_dirty() to call balance_dirty()

> > before returning. But if you add the balance_dirty() calls all over the
> > right places all should be _just_ fine as far I can tell.
>
> I don't agree, both for the reasons above and because doing a
> balance_dirty in mark_buffer_dirty tends to result in stalls in the
> *wrong* place, because it tends to stall in the middle of an operation,
> not before it has begun.  You end up stalling on metadata operations that
> shouldn't stall.  The stall thresholds for data vs metadata have to be
> different in order to make the system 'feel' right.  This is easily
> accomplished by trying to "allocate" the dirty buffers before you actually
> dirty them (by checking if there's enough slack in the dirty buffer
> margins before doing the operation).
>
>                 -ben

If reiserfs had good SMP, you could stall it anywhere, and the code could handle
that.  But we don't, and I bet others also don't, and we won't have it for some
time even though we are working on it.

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
