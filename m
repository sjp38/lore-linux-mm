Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA26593
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 11:52:08 -0400
Date: Thu, 25 Jun 1998 12:35:02 +0100
Message-Id: <199806251135.MAA00851@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Thread implementations...
In-Reply-To: <m1n2b23wqr.fsf@flinx.npwt.net>
References: <Pine.LNX.3.96dg4.980624210745.18727h-100000@twinlark.arctic.org>
	<m1n2b23wqr.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: Dean Gaudet <dgaudet-list-linux-kernel@arctic.org>, Richard Gooch <Richard.Gooch@atnf.CSIRO.AU>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 24 Jun 1998 23:56:28 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

> mmap, madvise(SEQUENTIAL),write 
> is easy to implement.  The mmap layer already does readahead, all we
> do is tell it not to be so conservative.

Swap readhead is also now possible.  However, madvise(SEQUENTIAL) needs
to do much more than this; it needs to aggressively track what region of
the vma is being actively used, and to unmap those areas no longer in
use.  (They can remain in cache until the memory is needed for something
else, of course.)  The madvise is only going to be important if the
whole file / vma does not fit into memory, so having advice that a piece
of memory not recently accessed is unlikely to be accessed again until
the next sequential pass is going to be very valuable.  It will prevent
us from having to swap out more useful stuff.

--Stephen
