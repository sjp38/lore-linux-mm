Date: Sun, 5 Aug 2007 13:33:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-Id: <20070805133301.107ce725.akpm@linux-foundation.org>
In-Reply-To: <20070805202112.GA32088@lazybastard.org>
References: <20070804192130.GA25346@elte.hu>
	<20070804211156.5f600d80@the-village.bc.nu>
	<20070804202830.GA4538@elte.hu>
	<20070804210351.GA9784@elte.hu>
	<20070804225121.5c7b66e0@the-village.bc.nu>
	<20070805072141.GA4414@elte.hu>
	<20070805085354.GC6002@1wt.eu>
	<20070805141708.GB25753@lazybastard.org>
	<1186336953.2777.17.camel@laptopd505.fenrus.org>
	<20070805183714.GA31606@lazybastard.org>
	<20070805202112.GA32088@lazybastard.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-8859-1?B?SvZybg==?= Engel <joern@logfs.org>
Cc: Ingo Molnar <mingo@elte.hu>, Arjan van de Ven <arjan@infradead.org>, Willy Tarreau <w@1wt.eu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sun, 5 Aug 2007 22:21:12 +0200 Jorn Engel <joern@logfs.org> wrote:

> On Sun, 5 August 2007 20:37:14 +0200, Jorn Engel wrote:
> > 
> > Guess I should throw in a kernel compile test as well, just to get a
> > feel for the performance.
> 
> Three runs each of noatime, relatime and atime, both with cold caches
> and with warm caches.  Scripts below.  Run on a Thinkpad T40, 1.5GHz,
> 2GiB RAM, 60GB 2.5" IDE disk, ext3.
> 
> Biggest difference between atime and noatime (median run, cold cache) is
> ~2.3%, nowhere near the numbers claimed by Ingo.  Ingo, how did you
> measure 10% and more?

Ingo had CONFIG_DEBUG_INFO=y, which generates heaps more writeout,
but no additional atime updates.

Ingo had a faster computer ;)  That will generate many more MB/sec
write traffic, so the cost of those atime seeks becomes proportionally
higher.  Basically: you're CPU-limited, Ingo is seek-limited.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
