Date: Thu, 5 Mar 1998 22:25:50 GMT
Message-Id: <199803052225.WAA01125@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: reverse pte lookups and anonymous private mappings; avl trees?
In-Reply-To: <Pine.LNX.3.91.980305001855.1439B-100000@mirkwood.dummy.home>
References: <199803042126.VAA01736@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.91.980305001855.1439B-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 5 Mar 1998 00:20:39 +0100 (MET), Rik van Riel
<H.H.vanRiel@fys.ruu.nl> said:

> On Wed, 4 Mar 1998, Stephen C. Tweedie wrote: 

>> don't seem to give us all that much extra, since we probably never
>> want to go out and explicitly search for all pages on such lists.
>> (That's assuming that the page aging and swapping scanner is
>> working by walking pages in physical address order, not by
>> traversing any other lists.)

> We just might want to do that. If we can _guarantee_ a certain
> number of free+(inactive&clean) pages, we can keep the number of
> free pages lower, and we can keep more pages longer in memory,
> giving more speed to the overall system.

I know --- that's precisely the point I was trying to make!  The
"inactive plus clean" pages are exactly the pages we need to keep on a
queue for rapid reclamation, and these pages are guaranteed not to be
mapped.  So, we can overload the queue links with the vma,vm_offset
values (which are only needed for mapped pages, which cannot be so
rapidly reclaimed).

We only have to keep the two structures separate if we ever need to
locate lists of mapped pages, and I was only planning to use unmapped
pages for the fast-reclaim lists (I don't like the idea of twiddling
process page tables from inside interrupts!).

Cheers,
 Stephen
