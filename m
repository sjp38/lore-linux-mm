Date: Thu, 22 Jan 2004 15:19:43 +0000
From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: 2.6.2-rc1-mm1
Message-ID: <20040122151943.GW21151@parcelfarce.linux.theplanet.co.uk>
References: <20040122013501.2251e65e.akpm@osdl.org> <20040122110342.A9271@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040122110342.A9271@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 22, 2004 at 11:03:42AM +0000, Christoph Hellwig wrote:
> > sysfs-class-06-raw.patch
> >   From: Greg KH <greg@kroah.com>
> >   Subject: [PATCH] add sysfs class support for raw devices [06/10]
> 
> This one exports get_gendisk, which is a no-go.

Moreover, it obviously leaks references to struct gendisk _and_ changes
semantics of RAW_SETBIND in incompatible way.

Consider that vetoed.  And yes, get_gendisk() issue alone would be enough.

Greg, please, RTFS to see at which point do we decide which driver will
be used by raw device.  It's _not_ RAW_SETBIND, it's open().  So where
your symlink should point is undecided until the same point.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
