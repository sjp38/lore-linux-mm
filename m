Date: Thu, 22 Jan 2004 16:41:24 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: 2.6.2-rc1-mm1
Message-ID: <20040123004124.GC16052@kroah.com>
References: <20040122013501.2251e65e.akpm@osdl.org> <20040122110342.A9271@infradead.org> <20040122151943.GW21151@parcelfarce.linux.theplanet.co.uk> <20040122233854.GA16052@kroah.com> <20040123002414.GA21151@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040123002414.GA21151@parcelfarce.linux.theplanet.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: viro@parcelfarce.linux.theplanet.co.uk
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 23, 2004 at 12:24:14AM +0000, viro@parcelfarce.linux.theplanet.co.uk wrote:
> On Thu, Jan 22, 2004 at 03:38:54PM -0800, Greg KH wrote:
> > On Thu, Jan 22, 2004 at 03:19:43PM +0000, viro@parcelfarce.linux.theplanet.co.uk wrote:
> > > Greg, please, RTFS to see at which point do we decide which driver will
> > > be used by raw device.  It's _not_ RAW_SETBIND, it's open().  So where
> > > your symlink should point is undecided until the same point.
> > 
> > I don't care about which driver is used by the raw device, I care about
> > which block device the raw device is "bound" to.  That happens at
> > RAW_SETBIND time, right?  We do this in the line:
> > 	rawdev->binding = bdget(dev);
> 
> No.  We have no fscking idea what device it is.  All we know is a device
> number.  No driver-related activity (including insmod, etc.) happens
> until open().
> 
> Among other things, RAW_SETBIND on inexistent device is a legitimate use.
> Which kills your "create a symlink at RAW_SETBIND" immediately - there
> might very well be nothing for it to point to.
> 
> You can bind /dev/raw0 to 8:0, then attach USB disk and then open
> /dev/raw0.  That ends up with /dev/raw0 becoming a raw alias for
> that disk.

Ah, ok, I didn't realize this, thanks for making it much clearer.  My
patch is horribly wrong then.  I like Andrew's patch of just marking it
obsolete :)

Andrew, feel free to drop my raw sysfs patch from your -mm tree for now.

thanks,

greg k-h
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
