Date: Wed, 14 May 2003 09:30:51 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: 2.5.69-mm5
Message-ID: <20030514163051.GA2250@kroah.com>
References: <CDD2FA891602624BB024E1662BC678ED843F91@mbi-00.mbi.ufl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CDD2FA891602624BB024E1662BC678ED843F91@mbi-00.mbi.ufl.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Jon K. Akers" <jka@mbi.ufl.edu>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 14, 2003 at 10:33:43AM -0400, Jon K. Akers wrote:
> I like to at least build the new stuff that comes out with Andrew's
> patches, and building the new gadget code that came out in -mm4 I got
> this when building as a module:
> 
> make -f scripts/Makefile.build obj=drivers/serial
> make -f scripts/Makefile.build obj=drivers/usb/gadget
>   gcc -Wp,-MD,drivers/usb/gadget/.net2280.o.d -D__KERNEL__ -Iinclude
> -Wall -Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing
> -fno-common -pipe -mpreferred-stack-boundary=2 -march=i686
> -Iinclude/asm-i386/mach-default -fomit-frame-pointer -nostdinc
> -iwithprefix include -DMODULE   -DKBUILD_BASENAME=net2280
> -DKBUILD_MODNAME=net2280 -c -o drivers/usb/gadget/net2280.o
> drivers/usb/gadget/net2280.c
> drivers/usb/gadget/net2280.c:2623: pci_ids causes a section type
> conflict

Do you get the same error on the latest -bk patch from Linus's tree?

And what CONFIG_USB_GADGET_* .config options do you have enabled?

thanks,

greg k-h
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
