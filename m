Date: Sat, 4 Aug 2007 22:28:30 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070804202830.GA4538@elte.hu>
References: <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070804211156.5f600d80@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> Either change is a big user/kernel interface change and no major 
> vendor targets desktop as primary market so I'm not suprised they 
> haven't done this. [...]

earlier in the thread it was claimed that Ubuntu is now defaulting to 
noatime+nodiratime, and has done so for several months. Could be one of 
the reasons why:

   http://www.google.com/trends?q=fedora%2C+ubuntu

> People just need to know about the performance differences - very few 
> realise its more than a fraction of a percent. I'm sure Gentoo will 
> use relatime the moment anyone knows its > 5% 8)

noatime,nodiratime gave 50% of wall-clock kernel rpm build performance 
improvement for Dave Jones, on a beefy box. Unless i misunderstood what 
you meant under 'fraction of a percent' your numbers are _WAY_ off. 
Atime updates are a _huge everyday deal_, from laptops to servers. 
Everywhere on the planet. Give me a Linux desktop anywhere and i can 
tell you whether it has atimes on or off, just by clicking around and 
using apps (without looking at the mount options). That's how i notice 
it that i forgot to turn off atime on any newly installed system - the 
system has weird desktop lags and unnecessary disk trashing.

> [...] Ext3 currently is a standards compliant file system. Turn off 
> atime and its very non standards compliant, turn to relatime and its 
> not standards compliant but nobody will break (which is good)

come on! Any standards testsuite needs tons of tweaks to the system to 
run through to completion. Mounting the filesystem atime will just be 
one more item in the long list of (mostly silly) 'needed for standards 
compliance' items (most of which nobody configures). What matters are 
the apps, and nary any app depends on atime, and those people who depend 
on them can turn on atime just fine. (it's the same as for extended 
attributes for example - and attributes are infinitely _more_ useful 
than atime.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
