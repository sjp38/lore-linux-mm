Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 6A5206B0068
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 09:29:51 -0400 (EDT)
Date: Mon, 16 Jul 2012 15:29:35 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: swap on eMMC and other flash
Message-ID: <20120716132935.GA20549@elf.ucw.cz>
References: <201203301744.16762.arnd@arndb.de>
 <201203301850.22784.arnd@arndb.de>
 <4F7C3CE2.5070803@intel.com>
 <201204041247.53289.arnd@arndb.de>
 <4F855CD7.1000902@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F855CD7.1000902@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adrian Hunter <adrian.hunter@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linaro-kernel@lists.linaro.org, linux-mm@kvack.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, kernel-team@android.com, "Rafael J. Wysocki" <rjw@sisk.pl>

On Wed 2012-04-11 13:28:39, Adrian Hunter wrote:
> On 04/04/12 15:47, Arnd Bergmann wrote:
> > On Wednesday 04 April 2012, Adrian Hunter wrote:
> >> On 30/03/12 21:50, Arnd Bergmann wrote:
> >>> (sorry for the duplicated email, this corrects the address of the android
> >>> kernel team, please reply here)
> >>>
> >>> On Friday 30 March 2012, Arnd Bergmann wrote:
> >>>
> >>>  We've had a discussion in the Linaro storage team (Saugata, Venkat and me,
> >>>  with Luca joining in on the discussion) about swapping to flash based media
> >>>  such as eMMC. This is a summary of what we found and what we think should
> >>>  be done. If people agree that this is a good idea, we can start working
> >>>  on it.
> >>
> >> There is mtdswap.
> > 
> > Ah, very interesting. I wasn't aware of that. Obviously we can't directly
> > use it on block devices that have their own garbage collection and wear
> > leveling built into them, but it's interesting to see how this was solved
> > before.
> > 
> > While we could build something similar that remaps blocks between an
> > eMMC device and the logical swap space that is used by the mm code,
> > my feeling is that it would be easier to modify the swap code itself
> > to do the right thing.
> > 
> >> Also the old Nokia N900 had swap to eMMC.
> >>
> >> The last I heard was that swap was considered to be simply too slow on hand
> >> held devices.
> > 
> > That's the part that we want to solve here. It has nothing to do with
> > handheld devices, but more with specific incompatibilities of the
> > block allocation in the swap code vs. what an eMMC device expects
> > to see for fast operation. If you write data in the wrong order on
> > flash devices, you get long delays that you don't get when you do
> > it the right way. The same problem exists for file systems, and is
> > being addressed there as well.
> > 
> >> As systems adopt more RAM, isn't there a decreasing demand for swap?
> > 
> > No. You would never be able to make hibernate work, no matter how much
> > RAM you add ;-)
> 
> Have you considered making hibernate work without swap?

It does work without swap. See userland suspend packages, where you
write the image is up-to you.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
