Date: Thu, 5 Mar 1998 00:20:39 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: reverse pte lookups and anonymous private mappings; avl trees?
In-Reply-To: <199803042126.VAA01736@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980305001855.1439B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Wed, 4 Mar 1998, Stephen C. Tweedie wrote:

> > +#define PgQ_Locked	0	/* page is unswappable - mlock()'d */
> > +#define PgQ_Active	1	/* page is mapped and active -> young */
> > +#define PgQ_Inactive	2	/* page is mapped, but hasn't been referenced recently -> old */
> > +#define PgQ_Swappable	3	/* page has no mappings, is dirty */
> > +#define PgQ_Swapping	4	/* page is being swapped */
> > +#define PgQ_Dumpable	5	/* page has no mappings, is not dirty, but is still in the page cache */
> 
> don't seem to give us all that much extra, since we probably never want
> to go out and explicitly search for all pages on such lists.  (That's
> assuming that the page aging and swapping scanner is working by walking
> pages in physical address order, not by traversing any other lists.)

We just might want to do that. If we can _guarantee_
a certain number of free+(inactive&clean) pages, we
can keep the number of free pages lower, and we can
keep more pages longer in memory, giving more speed
to the overall system.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
