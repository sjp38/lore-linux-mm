Date: Wed, 25 Feb 1998 23:05:18 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: PATCH: Swap shared pages (was: How to read-protect a vm_area?)
In-Reply-To: <199802251900.TAA00898@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980225225934.884C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Linus Torvalds <torvalds@transmeta.com>, Itai Nahshon <nahshon@actcom.co.il>, Alan Cox <alan@lxorguk.ukuu.org.uk>, paubert@iram.es, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Feb 1998, Stephen C. Tweedie wrote:

> Feel free to comment; I won't be working on this any time in the
> immediate future...

OK, then I'll focus on memory balancing, starting with
the following simple rules:
- buffer memory isn't allowed to grow larger than
  twice the size of the pagecache when nr_free_pages < free_pages_high
- if a cached inode uses more than half of the pagecache, and
  the pagecache is larger than 1/4th of memory, and
  nr_free_pages < 2 * free_pages_high (pfew!), then we won't
  allocate new pagecache memory to satisfy _that_ inode's demand,
  but steal memory from the pagecache or buffer instead.
- do some form of RSS balancing (later on, after we get the
  stats right again).
- document the files in /proc/sys/vm and /proc/sys/kernel
  (I've started, but really should finish the files tonight :-)

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
