Date: Fri, 5 Jul 2002 21:11:26 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: vm lock contention reduction
In-Reply-To: <3D26304C.51FAE560@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207052110590.8346-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jul 2002, Andrew Morton wrote:
> William Lee Irwin III wrote:
> > On Thu, Jul 04, 2002 at 07:18:34PM -0700, Andrew Morton wrote:
> > > Of course, that change means that we wouldn't be able to throttle
> > > page allocators against IO any more, and we'd have to do something
> > > smarter.  What a shame ;)
> >
> > This is actually necessary IMHO. Some testing I've been able to do seems
> > to reveal the current throttling mechanism as inadequate.
>
> I don't think so.  If you're referring to the situation where your
> 4G machine had 3.5G dirty pages without triggering writeback.
>
> That's not a generic problem.

But it is, mmap() and anonymous memory don't trigger writeback.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
