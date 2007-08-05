Date: Sun, 5 Aug 2007 13:43:28 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805134328.1a4474dd@the-village.bc.nu>
In-Reply-To: <20070805073709.GA6325@elte.hu>
References: <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	<20070804163733.GA31001@elte.hu>
	<alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>
	<46B4C0A8.1000902@garzik.org>
	<20070804191205.GA24723@lazybastard.org>
	<20070804192130.GA25346@elte.hu>
	<20070804211156.5f600d80@the-village.bc.nu>
	<20070804202830.GA4538@elte.hu>
	<20070804210351.GA9784@elte.hu>
	<20070804225121.5c7b66e0@the-village.bc.nu>
	<20070805073709.GA6325@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

> you try to put the blame into distribution makers' shoes but in reality, 
> had the kernel stepped forward with a neat .config option sooner 
> (combined with a neat boot option as well to turn it off), we'd have had 
> noatime systems 10 years ago. A new entry into relnotes and done. It's 

Sorry Ingo, having been in the distribution business for over ten years I
have to disagree. Kernel options that magically totally change the kernel
API and behaviour are exactly what a vendor does *NOT* want to have.

> Distro makers did not dare to do this sooner because some kernel 
> developers came forward with these mostly bogus arguments ... The impact 
> of atime is far better understood by the kernel community, so it is the 
> responsibility of _us_ to signal such things towards distributors, not 
> the other way around.

You are trying to put a bogus divide between kernel community and
developer community. Yet you know perfectly well that a large part of the
kernel community yourself included work for distribution vendors and are
actively building the distribution kernels.

You are perfectly positioned to provide timing examples to the Fedora
development team and make the case for FC8 beta going out that way. You
are perfectly able to propose, build and submit a FC7 extras package of
tuning which people can try in the meantime, but you haven't do so.

Other people in this discussion can do likewise for Debian, SuSE etc.

Your argument appears to be "I can't be bothered to use the due processes
of the distribution but I can do it quickly with an ugly kernel hack".
That is not the right approach. Propose it with your presented numbers to
fedora-devel and I'll be happy to back up such a proposal for the next FC
as will many other kernel folk I'm sure.

Heck, go write a piece for LWN with the benchmark numbers and how to
change your atime options. You'll make Jon happy and lots of folks read
it and will give feedback on improvements as a result.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
