Date: Thu, 5 Mar 1998 00:27:25 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: [uPATCH] small kswapd improvement ???
In-Reply-To: <199803042111.VAA01668@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980305002311.1439C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Mar 1998, Stephen C. Tweedie wrote:

> Regarding the tsk->swap_address stuff: swap_out_pmd() includes the line
> 
> 		tsk->swap_address = address + PAGE_SIZE;

Indeed, the tsk->swap_address = 0 might fit better in
swap_out(), and added to the switch statement at the
bottem, in the 0 case to be exact.

> One other observation while looking at this code: we currently walk over
> every process when swapping, and this is wrong.  We should only walk
> over each mm_struct once.  Another one for the list for 2.2.

Maybe we could give a run a serial number, and add that
number to the struct vma_struct. The serial number should
be updated each time we do the AGE_CLUSTER_SIZE thingy
because we ran out of processes with p->swap_cnt > 0.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
