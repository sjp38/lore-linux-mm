Date: Fri, 15 Sep 2000 19:28:43 +0200 (CEST)
From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [PATCH *] VM patch for 2.4.0-test8
In-Reply-To: <Pine.LNX.4.21.0009141351510.10822-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0009151915040.7748-100000@tux.rsn.hk-r.se>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Sep 2000, Rik van Riel wrote:

> On Wed, 13 Sep 2000, David S. Miller wrote:
> 
> > In page_launder() about halfway down there is this sequence of tests
> > on LRU pages:
> > 
> > if (!clearedbuf) {
> >  ...
> > } else if (!page->mapping) {
> >  ...
> > } else if (page_count(page) > 1) {
> > } else /* page->mapping && page_count(page) == 1 */ {
> >  ...
> > }
> > 
> > Above this sequence we've done a page_cache_get.
> 
> Indeed, you're right. This bug certainly explains some
> of the performance things I've seen in the stress test
> last night...
> 
> Btw, in case you're wondering ... the box /survived/
> a stress test that would get programs killed on quite
> a few "stable" kernels we've been shipping lately. ;)

Here comes a success report.

I've been using 2.4.0test8+2.4.0-t8-vmpatch2 for about a day now and the
performance is great.

I've just bought a new harddrive and I was copying a _lot_ of data to the
new drive and didn't notice anything axcept the HDD led flashing :)

And now I helped a friend back up his data while he converts to reiserfs.
I had a stream of 7-9MB/s down to my harddrive for quite a while and still
didn't notice anything. Everything ended up on the inactive list.

I've been trying to get my machine to swap but that seems hard with this
new patch :) I have 0kB of swap used after 8h uptime, and I have been
compiling, moving files between partitions and running md5sum on files
(that was a big problem before, everything ended up on the active list and
the swapping started and brought my machine down to a crawl)

I can mention that while backing up my friends data I had 7000-9000
interrupts per second and 10 000 - 12 000 context switches per second.
I was really impressed that I didn't notice anything. I remember that my
machine was terribly slow when it did over 5000 context switches with
vanilla test6.
(My machine is a pIII 700 with 256MB ram)

If anyone want more info or anything please feel free to mail me.
(Hopefully my mailserver is up, we've been experiencing some power
problems)

/Martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
