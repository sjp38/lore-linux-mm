Date: Thu, 13 Mar 2003 14:35:18 -0600 (CST)
From: Thomas Molina <tmolina@cox.net>
Subject: Re: 2.5.64-mm6
In-Reply-To: <20030313032615.7ca491d6.akpm@digeo.com>
Message-ID: <Pine.LNX.4.44.0303131419570.4241-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Mar 2003, Andrew Morton wrote:

> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.64/2.5.64-mm6/
> 
> . Added all of Russell King's PCMCIA changes.  If anyone tests this on
>   cardbus/PCMCIA machines please let us know.

I decided to try it because of this.  My test machine was a Compaq 
Presario 12XL325, PIII-650, RedHat 8.0 with updates.  The cardbus bridge 
is listed as a TI PCI1410 controller.  I've been doing daily bk pulls and 
compiles on this machine for some time with no problems noted on the 
resulting kernel.  On the cardbus interface I have an SMC wireless NIC as 
modules.  

I downloaded the mm-6 patch and a pristine 2.5.64 tarball.  After applying 
the patch I compiled with the standard configuration I've been using all 
along.  No problems were noted during the compile cycle.  During bootup 
the system locked up at the point where it did a modprobe uhci-hcd for the 
USB controller.  Nothing of interest was noted in the log.  I rebooted 
with nousb in the command line and got a good boot.  After working with 
this kernel for awhile I don't see anything out of the ordainary except 
that on a 2.5.64-bk kernel I get 330 Kbytes per second download speed 
whereas with mm6 I get 280 Kbytes per second.  Several runs show this is 
fairly consistent, with results within one or two percent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
