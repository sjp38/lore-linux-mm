Date: Fri, 30 Oct 1998 10:39:26 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: [patch] my latest oom stuff
In-Reply-To: <Pine.LNX.3.96.981030144018.999A-100000@dragon.bogus>
Message-ID: <Pine.LNX.3.95.981030103318.169A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 30 Oct 1998, Andrea Arcangeli wrote:

> Ok the last patch (the one with the FP_* flags) seems really perfect. I
> have put out a new whole patch against pre-2.1.127-2 (with the
> swap_duplicate() bogus check removed). 
> 
> ftp://e-mind.com/pub/linux/kernel-patches/oom-22...

For those of you having trouble getting to e-mind.com (70% loss from
here...), I've put a copy at:
http://www.kvack.org/~blah/patches/andrea-oom-22-pre-2.1.127-2.diff.gz

		-ben

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
