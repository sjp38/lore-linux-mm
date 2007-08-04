Subject: Re: [PATCH 00/23] per device dirty throttling -v8
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20070804202830.GA4538@elte.hu>
References: <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu>
	 <20070804103347.GA1956@elte.hu>
	 <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	 <20070804163733.GA31001@elte.hu>
	 <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>
	 <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org>
	 <20070804192130.GA25346@elte.hu>
	 <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu>
Content-Type: text/plain
Date: Sat, 04 Aug 2007 13:34:04 -0700
Message-Id: <1186259644.2777.12.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

> > People just need to know about the performance differences - very few 
> > realise its more than a fraction of a percent. I'm sure Gentoo will 
> > use relatime the moment anyone knows its > 5% 8)
> 
> noatime,nodiratime gave 50% of wall-clock kernel rpm build performance 
> improvement for Dave Jones, on a beefy box. Unless i misunderstood what 
> you meant under 'fraction of a percent' your numbers are _WAY_ off.

it's also a Watt or so of power if you have the AHCI ALPM patches in the
kernel (which are pending mainline inclusion)...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
