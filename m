Date: Wed, 14 May 2003 09:42:42 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: 2.5.69-mm5
Message-ID: <20030514164242.GA2352@kroah.com>
References: <CDD2FA891602624BB024E1662BC678ED843F9B@mbi-00.mbi.ufl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CDD2FA891602624BB024E1662BC678ED843F9B@mbi-00.mbi.ufl.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Jon K. Akers" <jka@mbi.ufl.edu>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 14, 2003 at 12:35:26PM -0400, Jon K. Akers wrote:
> Currently I do not use the -bk patches from Linus's tree, although I
> suppose I could give it a shot. 
> 
> My .config for that section follows:
> 
> #
> # USB support
> #
> # CONFIG_USB is not set
> CONFIG_USB_GADGET=y
> 
> #
> # USB Peripheral Controller Support
> #
> CONFIG_USB_NET2280=y
> 
> #
> # USB Gadget Drivers
> #
> CONFIG_USB_ZERO=m
> CONFIG_USB_ZERO_NET2280=y
> CONFIG_USB_ETH=y
> CONFIG_USB_ETH_NET2280=y

Yeah, you can't compile both of these drivers directly in the kernel at
the same time.  David Brownell posted a patch for this yesterday to lkml
and I'll send it on to Linus later on today.

thanks,

greg k-h
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
