Date: Wed, 22 Apr 1998 14:29:18 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: (reiserfs) Re: Maybe we can do 40 bits in June/July. (fwd)
In-Reply-To: <m1yawxoi36.fsf@flinx.npwt.net>
Message-ID: <Pine.LNX.3.95.980422140626.9664A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 22 Apr 1998, Eric W. Biederman wrote:
...
> My design:
> As I understand it the buffer cache is fine, so it is just a matter
> getting the page cache and the vma and the glue working.

The buffer cache is currently fine, but we do want to get rid of it...

> My thought is to make the page cache use generic keys. 
> This should help support things like the swapper inode a little
> better.  Still need a bit somewhere so we can coallese VMA's that have
> an inode but don't need continous keys.  That's for later.

Hmmm, if you've seen my rev_pte patch then you'll notice that *all* vmas
will soon need continuous keys... 

> For the common case of inodes have the those keys:
> page->key == page->offset >> PAGE_SHIFT.

Not a good idea unless support for a.out is dropped completely -- a better
choice would be to use 512 as a divisor; then pages can at least be at the
block offset as needed by a.out.

Something else to keep in mind is that we also need a mechanism to keep
metadata in the page cache (rather, per-inode metadata; fixed metadata can
just use its own inode).

> And of course get rid of page->offset.  The field name changes will to
> catch any old code that is out there.

That's a good idea.

		-ben
