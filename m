Subject: Re: [PATCH 00/23] per device dirty throttling -v8
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <alpine.LFD.0.999.0708041246530.5037@woody.linux-foundation.org>
References: <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
	 <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu>
	 <20070804103347.GA1956@elte.hu>
	 <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	 <20070804163733.GA31001@elte.hu>
	 <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>
	 <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org>
	 <20070804192130.GA25346@elte.hu> <20070804192615.GA25600@lazybastard.org>
	 <alpine.LFD.0.999.0708041246530.5037@woody.linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Date: Sat, 04 Aug 2007 13:13:19 -0700
Message-Id: <1186258399.2777.8.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jeff@garzik.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sat, 2007-08-04 at 12:47 -0700, Linus Torvalds wrote:
> 
> On Sat, 4 Aug 2007, JA?rn Engel wrote:
> > 
> > Given the choice between only "atime" and "noatime" I'd agree with you.
> > Heck, I use it myself.  But "relatime" seems to combine the best of both
> > worlds.  It currently just suffers from mount not supporting it in any
> > relevant distro.
> 
> Well, we could make it the default for the kernel (possibly under a 
> "fast-atime" config option), and then people can add "atime" or "noatime" 
> as they wish, since mount has supported _those_ options for a long time.


there is another trick possible (more involved though, Al will have to
jump in on that one I suspect): Have 2 types of "dirty inode" states;
one is the current dirty state (meaning the full range of ext3
transactions etc) and "lighter" state of "atime-dirty"; which will not
do the background syncs or journal transactions (so if your machine
crashes, you lose the atime update) but it does keep atime for most
normal cases and keeps it standard compliant "except after a crash".


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
