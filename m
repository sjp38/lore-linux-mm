Date: Wed, 10 Dec 1997 14:13:14 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Reply-To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Ideas for memory management hackers.
In-Reply-To: <199712101521.QAA25114@boole.fs100.suse.de>
Message-ID: <Pine.LNX.3.95.971210133924.5452C-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: Zlatko.Calusic@CARNet.hr, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 1997, Dr. Werner Fink wrote:

> In other words a better memory defragmentation is needed for 2.2, isn't it?
> A simple approach could be an addition address check during the scans
> in shrink_mmap (mm/filemap.c) instead of a freeing the first unused
> (random) page. This could be used in the first few priorities to free pages
> mostly useful for defragmentation.
> 
> An other approach is Ben's anonymous ageing of physical task pages
> found in http://www.kvack.org/~blah/patches/v2_1_47_ben1.gz ... 
> this approach gives a link of the pte of a page needed for ageing
> the page.

The past few times this has come up, the general argument from a few core
people is that if one *really* cares to find the pte's pointing to a page,
traversing the list of vma's attached to the inode, for which a pointer
already exists, would be sufficient.  Until I come up with something
really kick-ass, I really doubt the pte-list stuff will be included.

		-ben
