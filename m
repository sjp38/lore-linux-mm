Date: Tue, 26 Sep 2000 00:51:26 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000926005126.E5010@athlon.random>
References: <20000926002812.C5010@athlon.random> <Pine.LNX.4.21.0009251923070.4997-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251923070.4997-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Sep 25, 2000 at 07:26:56PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 07:26:56PM -0300, Rik van Riel wrote:
> IMHO this is a minor issue because:

I don't think it's a minor issue.

If you don't have reschedule point in your equivalent of shrink_mmap and this
1.5G will happen to be consecutive in the lru order (quite probably if it's
been pagedin at fast rate) then you may even hang in interruptible mode for
seconds as soon as somebody start reading from disk. 2.4.x have to scale for
dozen of Giga of RAM as there are archs supporting that amount of RAM.

> 2) you don't /want/ to run low on fs cache, you want

So I can't read more than the size that the fs cache can take? I must be
allowed to do that (they're 200 Mbyte of RAM that can be more than enough
if the server mainly generate pollution anyway).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
