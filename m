Received: by ug-out-1314.google.com with SMTP id c2so646169ugf
        for <linux-mm@kvack.org>; Sun, 05 Aug 2007 06:23:19 -0700 (PDT)
Date: Sun, 5 Aug 2007 15:22:31 +0200
From: Diego Calleja <diegocg@gmail.com>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-Id: <20070805152231.aba9428a.diegocg@gmail.com>
In-Reply-To: <20070805071320.GC515@elte.hu>
References: <20070804103347.GA1956@elte.hu>
	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	<20070804163733.GA31001@elte.hu>
	<alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>
	<46B4C0A8.1000902@garzik.org>
	<20070804191205.GA24723@lazybastard.org>
	<20070804192130.GA25346@elte.hu>
	<20070804211156.5f600d80@the-village.bc.nu>
	<20070804202830.GA4538@elte.hu>
	<20070804224834.5187f9b7@the-village.bc.nu>
	<20070805071320.GC515@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

El Sun, 5 Aug 2007 09:13:20 +0200, Ingo Molnar <mingo@elte.hu> escribio:

> Measurements show that noatime helps 20-30% on regular desktop 
> workloads, easily 50% for kernel builds and much more than that (in 
> excess of 100%) for file-read-intense workloads. We cannot just walk 


And as everybody knows in servers is a popular practice to disable it.
According to an interview to the kernel.org admins....

"Beyond that, Peter noted, "very little fancy is going on, and that is good
because fancy is hard to maintain." He explained that the only fancy thing
being done is that all filesystems are mounted noatime meaning that the
system doesn't have to make writes to the filesystem for files which are
simply being read, "that cut the load average in half."

I bet that some people would consider such performance hit a bug...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
