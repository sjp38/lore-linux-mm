Date: Sun, 5 Aug 2007 09:13:20 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805071320.GC515@elte.hu>
References: <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu> <20070804224834.5187f9b7@the-village.bc.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070804224834.5187f9b7@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > > People just need to know about the performance differences - very 
> > > few realise its more than a fraction of a percent. I'm sure Gentoo 
> > > will use relatime the moment anyone knows its > 5% 8)
> > 
> > noatime,nodiratime gave 50% of wall-clock kernel rpm build 
> > performance improvement for Dave Jones, on a beefy box. Unless i 
> > misunderstood what you meant under 'fraction of a percent' your 
> > numbers are _WAY_ off.
> 
> What numbers - I didn't quote any performance numbers ?

ok, i misunderstood your "very few realise its more than a fraction of a 
percent" sentence, i thought you were saying it's a fraction of a 
percent.

Measurements show that noatime helps 20-30% on regular desktop 
workloads, easily 50% for kernel builds and much more than that (in 
excess of 100%) for file-read-intense workloads. We cannot just walk 
past such a _huge_ performance impact so easily without even reacting to 
the performance arguments, and i'm happy Ubuntu picked up 
noatime,nodiratime and is whipping up the floor with Fedora on the 
desktop.

just look at the spontaneous feedback this thread prompted:

| ...For me, I would say 50% is not enough to describe the _visible_ 
| benefits... Not talking any specific number but past 10sec-1min+ 
| lagging in X is history, it's gone and I really don't miss it that 
| much... :-) Cannot reproduce even a second long delay anymore in 
| window focusing under considerable load as it's basically 
| instantaneous (I can see that it's loaded but doesn't affect the 
| feeling of responsiveness I'm now getting), even on some loads that I 
| couldn't previously even dream of... I still can get drawing lag a bit 
| by pushing enough stuff to swap but still it's definately quite well 
| under control, though rare 1-2 sec spikes in drawing appear due to 
| swap loads I think. ...And this is 2.6.21.5 so no fancies ala Ingo's 
| CFS or so yet...
|
| ...Thanks about this hint. :-)

much of the hard performance work we put into the kernel and into 
userspace is basically masked by the atime stupidity. How many man-years 
did it take to implement prelink? It has less of an impact than noatime! 
How much effort did we put into smart readahead and bootup 
optimizations? It has less of an impact than noatime.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
