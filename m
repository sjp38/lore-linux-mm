Date: Wed, 30 May 2001 17:27:41 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: http://ds9a.nl/cacheinfo project - please comment & improve
In-Reply-To: <20010530234806.C8629@home.ds9a.nl>
Message-ID: <Pine.LNX.4.21.0105301719310.5231-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bert hubert <ahu@ds9a.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 30 May 2001, bert hubert wrote:

> On Wed, May 30, 2001 at 04:54:12PM -0300, Marcelo Tosatti wrote:
> 
> > You're using the "address_space->dirty_pages" list to calculate the number
> > of dirty pages.
> 
> I was wondering about that. In limited testing I've never seen a non-0
> content of the dirty list. I ran:
> 
> dd if=/dev/zero of=test count=100000 &
> while true ; do ./cinfo test; done
> 
> And saw no dirty pages. 

Oops.

You will see no dirty pages here anyway --- data written through
write() is commited to the buffer cache directly. 

You can loop in each page into the clean_list and check their
"page->buffers" pointer.

If there are dirty buffer_head's there, you can count the page as dirty. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
