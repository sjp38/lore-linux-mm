Date: Mon, 2 Oct 2000 21:56:28 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re: simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer cache mgmt problem? (fwd)
Message-ID: <20001002215628.D21473@athlon.random>
References: <Pine.LNX.4.21.0010021630500.22539-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010021630500.22539-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 02, 2000 at 04:35:43PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 02, 2000 at 04:35:43PM -0300, Rik van Riel wrote:
> because we keep the buffer heads on active pages in memory...

A page can be the most active and the VM and never need bh on it after the
first pagein. Keeping the bh on it means wasting tons of memory for no good
reason.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
