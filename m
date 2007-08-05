Date: Sun, 5 Aug 2007 09:18:01 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805071801.GD515@elte.hu>
References: <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <46B4E161.9080100@garzik.org> <20070804224706.617500a0@the-village.bc.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070804224706.617500a0@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jeff Garzik <jeff@garzik.org>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > Linux has always been a "POSIX unless its stupid" type of system.  
> > For the upstream kernel, we should do the right thing -- noatime by 
> > default -- but allow distros and people that care about rigid 
> > compliance to easily change the default.
> 
> Linux has never been a "suprise your kernel interfaces all just 
> changed today" kernel, nor a "gosh you upgraded and didn't notice your 
> backups broke" kernel.

HSM uses atime as a _hint_. The only even remotely valid argument is 
Mutt, and even that one could easily be fixed _it is not even installed 
by default on most distros_ and nobody but me uses it ;) [and i've been 
using Mutt on noatime filesystems for years] So basically a single type 
of package and use-case (against tens of thousands of packages) held all 
of Linux desktop IO performance hostage for 10 years, to the tune of a 
20-30-50-100% performance degradation (depending on the workload)? Wow. 

And the atime situation is _so_ obvious, what will we do in the much 
less obvious cases?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
