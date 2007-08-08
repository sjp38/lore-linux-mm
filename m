Date: Thu, 9 Aug 2007 00:18:31 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070809001831.46147921@the-village.bc.nu>
In-Reply-To: <46BA1C08.4050904@garzik.org>
References: <20070804191205.GA24723@lazybastard.org>
	<20070804192130.GA25346@elte.hu>
	<20070804211156.5f600d80@the-village.bc.nu>
	<20070804202830.GA4538@elte.hu>
	<20070804210351.GA9784@elte.hu>
	<20070804225121.5c7b66e0@the-village.bc.nu>
	<20070805073709.GA6325@elte.hu>
	<20070805134328.1a4474dd@the-village.bc.nu>
	<20070805125433.GA22060@elte.hu>
	<20070805143708.279f51f8@the-village.bc.nu>
	<20070805180826.GD3244@elte.hu>
	<46BA09CC.7070007@tmr.com>
	<46BA1C08.4050904@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Bill Davidsen <davidsen@tmr.com>, Ingo Molnar <mingo@elte.hu>, J??rn Engel <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Wed, 08 Aug 2007 15:39:52 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Bill Davidsen wrote:
> > Being standards compliant is not an argument it's a design goal, a 
> > requirement. Standards compliance is like pregant, you are or you're 
> 
> Linux history says different.  There was always the "final 1%" of 
> compliance that required silliness we really did not want to bother with.

This isn't about the 1% however. Its about API and ABI. Changing the
default is a fairly evil ABI change. Telling everyone relatime is cool on
desktops and defaulting it in the distro is not an ABI change and is very
sensible

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
