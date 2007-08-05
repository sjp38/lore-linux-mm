Date: Sun, 5 Aug 2007 14:37:08 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805143708.279f51f8@the-village.bc.nu>
In-Reply-To: <20070805125433.GA22060@elte.hu>
References: <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>
	<46B4C0A8.1000902@garzik.org>
	<20070804191205.GA24723@lazybastard.org>
	<20070804192130.GA25346@elte.hu>
	<20070804211156.5f600d80@the-village.bc.nu>
	<20070804202830.GA4538@elte.hu>
	<20070804210351.GA9784@elte.hu>
	<20070804225121.5c7b66e0@the-village.bc.nu>
	<20070805073709.GA6325@elte.hu>
	<20070805134328.1a4474dd@the-village.bc.nu>
	<20070805125433.GA22060@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

> it's default off of course. A distro can turn it on or off.

...

> i've periodically pushed for a noatime distro kernel for like ... 5-10
> years and last time this argument came up [i brought it up 6 months ago]
> most of the distro kernel developer actually recommended using noatime,
> but it took only 1-2 kernel developers to come out with the
> 'compatibility' and 'compliance' boogeyman to scare the distro userspace
> people away from changing /etc/fstab.

And you honestly think that putting it in Kconfig as well as allowing
users to screw up horribly and creating incompatible defaults you can't
test for in a user space app where it matters is going to *change* this.

Do you really think anyone who said "noatime, compatibility, umm errr" is
going to say "noatime, compatibility, but hey its in Kconfig lets do it".
You argument doesn't hold up to minimal rational consideration. Posting
to the distribution devel list with: "Its a 50% performance win, we need
to fix these corner cases, here's a tmpwatch patch" is *exactly* what is
needed to change it, and Kconfig options are irrelevant to that.

Be serious and do this the proper way, propose it for FC8, go through the
proper due process. Otherwise the FC8 process will simply continue as
"umm err, compatibility" and it'll go nowhere.

You can't really complain about the CK scheduler and Con trying to do
stuff his own way without listening and then do this can you ? 

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
