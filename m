Date: Tue, 3 Oct 2000 00:18:34 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re: simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer cache mgmt problem? (fwd)
Message-ID: <20001003001834.A25467@athlon.random>
References: <Pine.LNX.4.10.10010021447310.2206-100000@penguin.transmeta.com> <Pine.LNX.4.21.0010021902530.1067-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010021902530.1067-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 02, 2000 at 07:08:20PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 02, 2000 at 07:08:20PM -0300, Rik van Riel wrote:
> Yes it has. The write order in flush_dirty_buffers() is the order
> in which the pages were written. This may be different from the
> LRU order and could give us slightly better IO performance.

And it will forbid us to use barriers in software elevator and in SCSI hardware
to avoid having to wait I/O completation every time a journaling fs needs to do
ordered writes. The write ordering must remain irrelevant to the page-LRU
order.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
