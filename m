Date: Wed, 30 May 2001 16:54:12 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: http://ds9a.nl/cacheinfo project - please comment & improve
In-Reply-To: <20010527222020.A25390@home.ds9a.nl>
Message-ID: <Pine.LNX.4.21.0105301648290.5231-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bert hubert <ahu@ds9a.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 27 May 2001, bert hubert wrote:

> Hello mm people!
> 
> I've written a module plus a tiny userspace program to query the page
> cache. In short:
> 
> $ cinfo /lib/libc.so.6
> /lib/libc.so.6: 182 of 272 (66.91%) pages in the cache, of which 0 (0.00%)
> are dirty
> 
> Now, I'm a complete and utter beginner when it comes to kernelcoding. Also,
> this is very much a 'release early, release often'-release. In other words,
> it sucks & I know.
> 
> So I would like to ask you to look at it and send comments/patches to me.
> I'm especially interested in architectural decisions - I currently export
> data over a filesystem (cinfofs), which may or not be right.
> 
> The tarball (http://ds9a.nl/cacheinfo/cinfo-0.1.tar.gz) contains 2 manpages
> which very lightly document how it works.

Hi Bert, 

You're using the "address_space->dirty_pages" list to calculate the number
of dirty pages.

Its interesting to note that pages on this list may not be really dirty
since we don't mark them clean when writting them out. (we only do that at
fdatasync/fsync time) 

So I suggest you to check for the PG_dirty (with the PageDirty macro) bit
on pages of that list to know if they are really dirty. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
