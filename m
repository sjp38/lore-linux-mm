Date: Wed, 4 Mar 1998 21:11:24 GMT
Message-Id: <199803042111.VAA01668@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [uPATCH] small kswapd improvement ???
In-Reply-To: <Pine.LNX.3.91.980304124951.20479B-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.95.980303201156.14224A-100000@as200.spellcast.com>
	<Pine.LNX.3.91.980304124951.20479B-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Regarding the tsk->swap_address stuff: swap_out_pmd() includes the line

		tsk->swap_address = address + PAGE_SIZE;

so the setting of tsk->swap_address to zero is only temporary.  Indeed,
I can't see how we can block between setting address to 0 and setting it
forward in swap_out_pmd, so we should only allow anybody to see the 0
value if there is truly nothing left to swap in the process's vm space.

Has anybody verified that this change alone, without any other of Rik's
changes, improves performance?

One other observation while looking at this code: we currently walk over
every process when swapping, and this is wrong.  We should only walk
over each mm_struct once.  Another one for the list for 2.2.

Cheers,
 Stephen.
