Received: from flinx.npwt.net (root@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA23672
	for <linux-mm@kvack.org>; Sun, 26 Jul 1998 11:05:56 -0400
Date: Sun, 26 Jul 1998 09:49:02 -0500 (CDT)
From: Eric W Biederman <eric@flinx.npwt.net>
Reply-To: ebiederm+eric@npwt.net
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <87iukovq42.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.4.02.9807260941230.276-100000@iddi.npwt.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On 23 Jul 1998, Zlatko Calusic wrote:

> "Stephen C. Tweedie" <sct@redhat.com> writes:
> 
> > Hi,
> > 
> > On 20 Jul 1998 11:15:12 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> > said:
> > 
> > > I don't know if its easy, but we probably should get rid of buffer
> > > cache completely, at one point in time. It's hard to balance things
> > > between two caches, not to mention other memory objects in kernel.
> > 
> > No, we need the buffer cache for all sorts of things.  You'd have to
> > reinvent it if you got rid of it, since it is the main mechanism by
> > which we can reliably label IO for the block device driver layer, and we
> > also cache non-page-aligned filesystem metadata there.
> 
> Even I didn't investigate it that lot, I still see Erics work on
> adding dirty page functionality as a step toward this.

>From where I sit it looks completly possible to give the buffer cache a
fake inode, and have it use the same mechanisms that I have developed for
handling other dirty data in the page cache.  It should also be possible
in this effort to simplify the buffer_head structure as well.

As time permits I'll move in that direction.

Eric

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
