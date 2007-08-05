Date: Sun, 5 Aug 2007 14:54:33 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805125433.GA22060@elte.hu>
References: <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu> <20070804210351.GA9784@elte.hu> <20070804225121.5c7b66e0@the-village.bc.nu> <20070805073709.GA6325@elte.hu> <20070805134328.1a4474dd@the-village.bc.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070805134328.1a4474dd@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > you try to put the blame into distribution makers' shoes but in 
> > reality, had the kernel stepped forward with a neat .config option 
> > sooner (combined with a neat boot option as well to turn it off), 
> > we'd have had noatime systems 10 years ago. A new entry into 
> > relnotes and done. It's
> 
> Sorry Ingo, having been in the distribution business for over ten 
> years I have to disagree. Kernel options that magically totally change 
> the kernel API and behaviour are exactly what a vendor does *NOT* want 
> to have.

it's default off of course. A distro can turn it on or off.

> > Distro makers did not dare to do this sooner because some kernel 
> > developers came forward with these mostly bogus arguments ... The 
> > impact of atime is far better understood by the kernel community, so 
> > it is the responsibility of _us_ to signal such things towards 
> > distributors, not the other way around.
> 
> You are trying to put a bogus divide between kernel community and 
> developer community. Yet you know perfectly well that a large part of 
> the kernel community yourself included work for distribution vendors 
> and are actively building the distribution kernels.

i've periodically pushed for a noatime distro kernel for like ... 5-10
years and last time this argument came up [i brought it up 6 months ago]
most of the distro kernel developer actually recommended using noatime,
but it took only 1-2 kernel developers to come out with the
'compatibility' and 'compliance' boogeyman to scare the distro userspace
people away from changing /etc/fstab.

so yes, things like this needs a clear message from the kernel folks,
and a kernel option for that is a pretty good way of doing it.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
