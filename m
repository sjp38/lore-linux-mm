Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA20250
	for <linux-mm@kvack.org>; Tue, 30 Jun 1998 04:33:12 -0400
Subject: Re: Thread implementations...
References: <Pine.LNX.3.96dg4.980624210745.18727h-100000@twinlark.arctic.org>
	<m1n2b23wqr.fsf@flinx.npwt.net>
	<199806251135.MAA00851@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 30 Jun 1998 01:40:35 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Thu, 25 Jun 1998 12:35:02 +0100
Message-ID: <m1sokn8k9o.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Dean Gaudet <dgaudet-list-linux-kernel@arctic.org>, Richard Gooch <Richard.Gooch@atnf.CSIRO.AU>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:

ST> Hi,
ST> On 24 Jun 1998 23:56:28 -0500, ebiederm+eric@npwt.net (Eric
ST> W. Biederman) said:

>> mmap, madvise(SEQUENTIAL),write 
>> is easy to implement.  The mmap layer already does readahead, all we
>> do is tell it not to be so conservative.

ST> Swap readhead is also now possible.  However, madvise(SEQUENTIAL) needs
ST> to do much more than this; 

In the long term I agree.  We can get a close approximation to the
proper behavior by simply doing aggressive readahead.  This is doable
now, and should work in the presence of multiple readers.

ST> it needs to aggressively track what region of
ST> the vma is being actively used, and to unmap those areas no longer in
ST> use.  (They can remain in cache until the memory is needed for something
ST> else, of course.)  The madvise is only going to be important if the
ST> whole file / vma does not fit into memory, 

Actally it will be important if the whole working set of data, (which
in a web server would be _all_ of it's files is too large to fit into
memory).  Each file /vma may fit in fine.

ST> so having advice that a piece
ST> of memory not recently accessed is unlikely to be accessed again until
ST> the next sequential pass is going to be very valuable.  It will prevent
ST> us from having to swap out more useful stuff.

Agreed.

Eric
