Received: from crux.tip.CSIRO.AU (crux.tip.CSIRO.AU [130.155.194.32])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA23270
	for <linux-mm@kvack.org>; Wed, 24 Jun 1998 23:54:02 -0400
Date: Thu, 25 Jun 1998 13:53:36 +1000
Message-Id: <199806250353.NAA17617@vindaloo.atnf.CSIRO.AU>
From: Richard Gooch <Richard.Gooch@atnf.CSIRO.AU>
Subject: Re: Thread implementations...
In-Reply-To: <Pine.LNX.3.96dg4.980624210745.18727h-100000@twinlark.arctic.org>
References: <m1u35a4fz8.fsf@flinx.npwt.net>
	<Pine.LNX.3.96dg4.980624210745.18727h-100000@twinlark.arctic.org>
Sender: owner-linux-mm@kvack.org
To: Dean Gaudet <dgaudet-list-linux-kernel@arctic.org>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dean Gaudet writes:
> 
> 
> On 24 Jun 1998, Eric W. Biederman wrote:
> 
> > >>>>> "RG" == Richard Gooch <Richard.Gooch@atnf.CSIRO.AU> writes:
> > 
> > RG> If we get madvise(2) right, we don't need sendfile(2), correct?
> > 
> > It looks like it from here.  As far as madvise goes, I think we need
> > to implement madvise(2) as:
> 
> ... note that mmap() requires a bunch of kernel structures set up to map
> things into the program's memory space... when in reality the program
> doesn't care at all about the bytes.  (And then there's process address
> space limitations...)  sendfile() and such don't have these problems, and
> it may be far more simple to implement sendfile() than it would be to put
> all the hints and such into the mm layer to get mmap() performance up to
> the same level. 

This may be true, but my point is that we *need* a decent madvise(2)
implementation. It will be use to a greater range of applications than
sendfile(2).

				Regards,

					Richard....
