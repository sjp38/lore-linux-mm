Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
Date: Tue, 7 Aug 2001 20:13:59 +0200
References: <292520000.997205190@tiny>
In-Reply-To: <292520000.997205190@tiny>
MIME-Version: 1.0
Message-Id: <0108072013590B.02365@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <mason@suse.com>, Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 August 2001 19:26, Chris Mason wrote:
> On Tuesday, August 07, 2001 10:04:05 AM -0700 Linus Torvalds
>
> <torvalds@transmeta.com> wrote:
> > On Tue, 7 Aug 2001, Linus Torvalds wrote:
> >> Sorry, I should have warned people: pre5 is a test-release that was
> >> intended solely for Leonard Zubkoff who has been helping with
> >> trying to debug a FS livelock condition.
> >
> > So I _think_ that what happens is:
> >  - alloc_pages() itself isn't making any progress, because it's
> > called with GFP_NOFS and thus cannot touch a lot of the pages.
> >  - we wake up kswapd to try to help, but kswapd doesn't do anything
> >    because it thinks things are fine.
>
> Which filesystem?  If its one of the journaled ones, other processes
> might be waiting on the log trying to flush things out.

xfs.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
