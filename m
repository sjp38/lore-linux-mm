Message-ID: <393E8A68.8DA3F4AB@reiser.to>
Date: Wed, 07 Jun 2000 10:46:16 -0700
From: Hans Reiser <hans@reiser.to>
MIME-Version: 1.0
Subject: Re: reiserfs being part of the kernel: it's not just the code
References: <Pine.LNX.4.10.10006060811120.15888-100000@dax.joh.cam.ac.uk> <393CA40C.648D3261@reiser.to> <20000606114851.A30672@home.ds9a.nl> <393CBBB8.554A0D2A@reiser.to> <20000606172606.I25794@redhat.com> <393D37D1.1BC61DC3@reiser.to> <20000606205447.T23701@redhat.com> <393DACC8.5DB60A81@reiser.to> <20000607120030.D29432@redhat.com>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Tue, Jun 06, 2000 at 07:00:40PM -0700, Hans Reiser wrote:
> >
> > Do I miss a finepoint, or can this reservation API be as simple as using an
> > agreed on counter for total system pinned pages which is constrained to some
> > percentage of memory?  I think we all discussed all of this last year, and the
> > workshop Riel tried to organize sadly never happened.
> 
> It's a good bit more complex than that.  We need not only that reservation
> layer, but also a new notification mechanism to invoke early commit if
> we exhaust the reservation limit, and a way of interacting with dirty
> pages (which are not yet part of any transaction, but which may not be
> flushable to disk without a new transaction being incurred).  The dirty
> mmaped data case is particularly nasty: we have very little VM
> infrastructure right now which is suitable for fixing that.

Have the FS stall if the limit is reached, and if the limit is reached, increase
memory pressure invoking the mechanism that will drive allocate on flush.

The FS needs a lot of code, VFS needs something around ten lines, yes?

> 
> > Perhaps we should do a
> > workshop July 5 at the Libre Software conference in France?  Probably this issue
> > will already be solved by then, but there are plenty of other discussions to
> > have in the vicinity of this problem.
> 
> Who will be at Usenix in San Diego in a couple of weeks' time?  There
> will certainly be some of the XFS and GFS people there, and I'll be
> around all week.
> 
> Cheers,
>  Stephen

None of the ReiserFS team will be there.  I can see you at the UK thing, I know
you are planning on going there.  If it is the Libre conference, I can probably
get zam and any other key people flown there is the thing.  You don't have to
attend the whole conference.... I can't because I am speaking at the UK one
also....  If you have a different conference you prefer, see if you can get
people flown there....

Hans
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
