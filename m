Date: Mon, 16 Mar 1998 22:59:29 GMT
Message-Id: <199803162259.WAA02995@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: PATCH: rev_pte_1 -- please test
In-Reply-To: <Pine.LNX.3.95.980312003121.31104A-100000@kanga.kvack.org>
References: <Pine.LNX.3.95.980312003121.31104A-100000@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: sct@dcs.ed.ac.uk, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ben,

A first quick comment on the new vma stuff:

Hmm, you've overloaded the vma/vm_offset stuff with the inode queues!
That's OK in principle --- the swap cache stuff currently maintains both
the per-inode page lists AND the hash lists, but only the hash lists are
strictly necessary so I guess we can live with that.  

There's also the guts of a page queue implementation --- have you got
any firmer plans for that?  I'm still uncertain about the benefits of
having these queues, except for the obvious use of the dumpable list.

Cheers,
 Stephen.
