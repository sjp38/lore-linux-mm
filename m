Date: Wed, 3 Jun 1998 17:01:03 -0400 (8UU)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Bug in do_munmap (fwd)
In-Reply-To: <Pine.LNX.3.95.980603195556.3900B-100000@localhost>
Message-ID: <Pine.LNX.3.95.980603165806.25288A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Perry Harrington <pedward@sun4.apsoft.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> I think I found the problem.  In zap_page_range:
...
> As you can see, dir is never freed.  If you look at zap_pmd_range, dir
> is used as a lookup point.  dir is what's being left around after the
> mmap.  The reason that this isn't a system wide memory leak is because
> the pages are freed when the process is reaped. Does this sound right?

Even if this particular aspect of it is fixed, the user can still bring
down the system by doing an anon mmap of 1 page at each 4MB boundry...
The correct fix is to have some sort of ulimit on the size of page tables,
or to make page tables swappable (uh-oh, that's a toughie fraught with
races).

		-ben
