Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA23770
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 01:31:18 -0400
Subject: Re: Thread implementations...
References: <Pine.LNX.3.96dg4.980624210745.18727h-100000@twinlark.arctic.org>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 24 Jun 1998 23:56:28 -0500
In-Reply-To: Dean Gaudet's message of Wed, 24 Jun 1998 21:12:59 -0700 (PDT)
Message-ID: <m1n2b23wqr.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Dean Gaudet <dgaudet-list-linux-kernel@arctic.org>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, Richard Gooch <Richard.Gooch@atnf.CSIRO.AU>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "DG" == Dean Gaudet <dgaudet-list-linux-kernel@arctic.org> writes:

DG> On 24 Jun 1998, Eric W. Biederman wrote:

>> >>>>> "RG" == Richard Gooch <Richard.Gooch@atnf.CSIRO.AU> writes:
>> 
RG> If we get madvise(2) right, we don't need sendfile(2), correct?
>> 
>> It looks like it from here.  As far as madvise goes, I think we need
>> to implement madvise(2) as:

DG> ... note that mmap() requires a bunch of kernel structures set up to map
DG> things into the program's memory space... when in reality the program
DG> doesn't care at all about the bytes.  (And then there's process address
DG> space limitations...)  sendfile() and such don't have these problems, and
DG> it may be far more simple to implement sendfile() than it would be to put
DG> all the hints and such into the mm layer to get mmap() performance up to
DG> the same level. 

mmap, madvise(SEQUENTIAL),write 
is easy to implement.  The mmap layer already does readahead, all we
do is tell it not to be so conservative.

Meanwhile to write sendfile, you need to do all of the same work
(except the page tables) without an interface to do it with.
madvise looks simpler from here.

Eric
