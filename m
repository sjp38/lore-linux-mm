Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA22198
	for <linux-mm@kvack.org>; Fri, 24 Apr 1998 16:33:44 -0400
Date: Fri, 24 Apr 1998 21:32:13 +0100
Message-Id: <199804242032.VAA00961@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: filemap_nopage is broken!!
In-Reply-To: <m1wwcgm48r.fsf@flinx.npwt.net>
References: <m1vhs1oa10.fsf@flinx.npwt.net>
	<199804232201.XAA02883@dax.dcs.ed.ac.uk>
	<m1wwcgm48r.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 23 Apr 1998 19:51:16 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

>>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:
ST> I don't think this is necessarily a problem.  The kernel simply does not
ST> guarantee full correspondance semantics between filesystem updates and
ST> the page cache for non-aligned pages, but then again, it is not required
ST> to --- it is not even required to support such mmaps, so I can live with
ST> an undefined behaviour in this case!

> Ah, but suppose we have a mythological a.out programmer.
> This programmer could run a program, doesn't like the result, compiles
> a new version which overwrites the old, and attempts to execute the
> new program.  And executes the old!

> There may be a lock in there that I haven't spotted, and likely there
> will be a truncation when the file is overwritten which would flush
> the page cache but it is possible there isn't.

There is.  truncate_inode_pages() will invalidate all of the mappings
when a file is either truncated or deleted.  Any overwrite of the file
will do the right thing.

> I doubt it will be anything like a show stopper for 2.2 but if this
> code get's touched it should be fixed to do something consistent.  

I don't think there's any problem.

--Stephen
