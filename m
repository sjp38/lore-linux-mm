Received: from twinlark.arctic.org (twinlark.arctic.org [204.62.130.91])
	by kvack.org (8.8.7/8.8.7) with SMTP id XAA23219
	for <linux-mm@kvack.org>; Wed, 24 Jun 1998 23:50:35 -0400
Date: Wed, 24 Jun 1998 21:12:59 -0700 (PDT)
From: Dean Gaudet <dgaudet-list-linux-kernel@arctic.org>
Subject: Re: Thread implementations...
In-Reply-To: <m1u35a4fz8.fsf@flinx.npwt.net>
Message-ID: <Pine.LNX.3.96dg4.980624210745.18727h-100000@twinlark.arctic.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: Richard Gooch <Richard.Gooch@atnf.CSIRO.AU>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On 24 Jun 1998, Eric W. Biederman wrote:

> >>>>> "RG" == Richard Gooch <Richard.Gooch@atnf.CSIRO.AU> writes:
> 
> RG> If we get madvise(2) right, we don't need sendfile(2), correct?
> 
> It looks like it from here.  As far as madvise goes, I think we need
> to implement madvise(2) as:

... note that mmap() requires a bunch of kernel structures set up to map
things into the program's memory space... when in reality the program
doesn't care at all about the bytes.  (And then there's process address
space limitations...)  sendfile() and such don't have these problems, and
it may be far more simple to implement sendfile() than it would be to put
all the hints and such into the mm layer to get mmap() performance up to
the same level. 

Dean
