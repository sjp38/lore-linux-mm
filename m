Date: Fri, 5 Jul 2002 16:11:13 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: vm lock contention reduction
Message-ID: <20020705231113.GA25360@holomorphy.com>
References: <3D24F869.2538BC08@zip.com.au> <Pine.LNX.4.44L.0207042244590.6047-100000@imladris.surriel.com> <3D2501FA.4B14EB14@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D2501FA.4B14EB14@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 04, 2002 at 07:18:34PM -0700, Andrew Morton wrote:
> Of course, that change means that we wouldn't be able to throttle
> page allocators against IO any more, and we'd have to do something
> smarter.  What a shame ;)

This is actually necessary IMHO. Some testing I've been able to do seems
to reveal the current throttling mechanism as inadequate.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
