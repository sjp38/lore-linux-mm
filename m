Received: from twinlark.arctic.org (twinlark.arctic.org [204.62.130.91])
	by kvack.org (8.8.7/8.8.7) with SMTP id QAA28138
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 16:08:19 -0400
Date: Thu, 25 Jun 1998 13:31:59 -0700 (PDT)
From: Dean Gaudet <dgaudet-list-linux-kernel@arctic.org>
Subject: Re: Thread implementations...
In-Reply-To: <199806251135.MAA00851@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96dg4.980625132735.17730U-100000@twinlark.arctic.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, Richard Gooch <Richard.Gooch@atnf.CSIRO.AU>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Thu, 25 Jun 1998, Stephen C. Tweedie wrote:

> Hi,
> 
> On 24 Jun 1998 23:56:28 -0500, ebiederm+eric@npwt.net (Eric
> W. Biederman) said:
> 
> > mmap, madvise(SEQUENTIAL),write 
> > is easy to implement.  The mmap layer already does readahead, all we
> > do is tell it not to be so conservative.
> 
> Swap readhead is also now possible.  However, madvise(SEQUENTIAL) needs
> to do much more than this; it needs to aggressively track what region of
> the vma is being actively used, and to unmap those areas no longer in
> use.

Remember it's *regions* not just a region.  An http/ftp server sends the
same file over and over and over.  There are many cursors moving
sequentially within the same file.  A threaded http/ftp server will have a
single mmap, and multiple users of that mmap. 

Dean
