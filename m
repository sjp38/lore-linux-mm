Date: Wed, 7 Jun 2000 12:00:30 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: reiserfs being part of the kernel: it's not just the code
Message-ID: <20000607120030.D29432@redhat.com>
References: <Pine.LNX.4.10.10006060811120.15888-100000@dax.joh.cam.ac.uk> <393CA40C.648D3261@reiser.to> <20000606114851.A30672@home.ds9a.nl> <393CBBB8.554A0D2A@reiser.to> <20000606172606.I25794@redhat.com> <393D37D1.1BC61DC3@reiser.to> <20000606205447.T23701@redhat.com> <393DACC8.5DB60A81@reiser.to>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <393DACC8.5DB60A81@reiser.to>; from hans@reiser.to on Tue, Jun 06, 2000 at 07:00:40PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <hans@reiser.to>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jun 06, 2000 at 07:00:40PM -0700, Hans Reiser wrote:
> 
> Do I miss a finepoint, or can this reservation API be as simple as using an
> agreed on counter for total system pinned pages which is constrained to some
> percentage of memory?  I think we all discussed all of this last year, and the
> workshop Riel tried to organize sadly never happened.

It's a good bit more complex than that.  We need not only that reservation
layer, but also a new notification mechanism to invoke early commit if 
we exhaust the reservation limit, and a way of interacting with dirty
pages (which are not yet part of any transaction, but which may not be
flushable to disk without a new transaction being incurred).  The dirty
mmaped data case is particularly nasty: we have very little VM 
infrastructure right now which is suitable for fixing that.

> Perhaps we should do a
> workshop July 5 at the Libre Software conference in France?  Probably this issue
> will already be solved by then, but there are plenty of other discussions to
> have in the vicinity of this problem.

Who will be at Usenix in San Diego in a couple of weeks' time?  There
will certainly be some of the XFS and GFS people there, and I'll be 
around all week.

Cheers, 
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
