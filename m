Date: Mon, 2 Oct 2000 22:17:18 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re: simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer cache mgmt problem? (fwd)
Message-ID: <20001002221718.B21995@athlon.random>
References: <20001002215628.D21473@athlon.random> <Pine.LNX.4.21.0010021658040.1067-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010021658040.1067-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 02, 2000 at 04:59:57PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 02, 2000 at 04:59:57PM -0300, Rik van Riel wrote:
> Linus, I remember you saying some time ago that you would
> like to keep the buffer heads on a page around so we'd
> have them at the point where we need to swap out again.

That's one of the basic differences between the 2.2.x and 2.4.x
page cache design. We don't reclaim the buffers at I/O completion
time anymore in 2.4.x but we reclaim them only later when we run
low on memory.

Forbidding the bh to be reclaimed when we run low on memory is a bug
and I don't think Linus ever suggested that.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
