content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: 2.5.69-mm5
Date: Wed, 14 May 2003 12:35:26 -0400
Message-ID: <CDD2FA891602624BB024E1662BC678ED843F9B@mbi-00.mbi.ufl.edu>
From: "Jon K. Akers" <jka@mbi.ufl.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently I do not use the -bk patches from Linus's tree, although I
suppose I could give it a shot. 

My .config for that section follows:

#
# USB support
#
# CONFIG_USB is not set
CONFIG_USB_GADGET=y

#
# USB Peripheral Controller Support
#
CONFIG_USB_NET2280=y

#
# USB Gadget Drivers
#
CONFIG_USB_ZERO=m
CONFIG_USB_ZERO_NET2280=y
CONFIG_USB_ETH=y
CONFIG_USB_ETH_NET2280=y


I also had the USB_ETH series set for modules and got the same result.

> -----Original Message-----
> From: Greg KH [mailto:greg@kroah.com]
> Sent: Wednesday, May 14, 2003 12:31 PM
> To: Jon K. Akers
> Cc: Andrew Morton; linux-kernel@vger.kernel.org; linux-mm@kvack.org
> 
> On Wed, May 14, 2003 at 10:33:43AM -0400, Jon K. Akers wrote:
> > I like to at least build the new stuff that comes out with Andrew's
> > patches, and building the new gadget code that came out in -mm4 I
got
> > this when building as a module:
> >
> > make -f scripts/Makefile.build obj=drivers/serial
> > make -f scripts/Makefile.build obj=drivers/usb/gadget
> >   gcc -Wp,-MD,drivers/usb/gadget/.net2280.o.d -D__KERNEL__ -Iinclude
> > -Wall -Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing
> > -fno-common -pipe -mpreferred-stack-boundary=2 -march=i686
> > -Iinclude/asm-i386/mach-default -fomit-frame-pointer -nostdinc
> > -iwithprefix include -DMODULE   -DKBUILD_BASENAME=net2280
> > -DKBUILD_MODNAME=net2280 -c -o drivers/usb/gadget/net2280.o
> > drivers/usb/gadget/net2280.c
> > drivers/usb/gadget/net2280.c:2623: pci_ids causes a section type
> > conflict
> 
> Do you get the same error on the latest -bk patch from Linus's tree?
> 
> And what CONFIG_USB_GADGET_* .config options do you have enabled?
> 
> thanks,
> 
> greg k-h
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
