Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA17561
	for <linux-mm@kvack.org>; Thu, 23 Apr 1998 20:18:21 -0400
Date: Thu, 23 Apr 1998 23:01:32 +0100
Message-Id: <199804232201.XAA02883@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: filemap_nopage is broken!!
In-Reply-To: <m1vhs1oa10.fsf@flinx.npwt.net>
References: <m1vhs1oa10.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 22 Apr 1998 15:51:07 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

> Now if the following sequence of actions occure.
> a) A page is mapped privately with poor alignment.
> b) That part of the file is written again.
> c) The page is again mapped privately with poor alignment.

> When the page cache page is not scavenged between a and c, the same
> data is read, despite the fact it has changed on disk, and in the
> aligned page cache page!

> That is broken behavior.

I don't think this is necessarily a problem.  The kernel simply does not
guarantee full correspondance semantics between filesystem updates and
the page cache for non-aligned pages, but then again, it is not required
to --- it is not even required to support such mmaps, so I can live with
an undefined behaviour in this case!

--Stephen
