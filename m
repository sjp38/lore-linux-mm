Date: Sun, 5 Aug 2007 14:56:49 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805125649.GB22060@elte.hu>
References: <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu> <20070804210351.GA9784@elte.hu> <20070804225121.5c7b66e0@the-village.bc.nu> <20070805072141.GA4414@elte.hu> <20070805134750.691e2e74@the-village.bc.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070805134750.691e2e74@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > > we can move from atime to noatime by default on FC8 with 
> > > appropriate release note warnings and having a couple of betas to 
> > > find out what other than mutt goes boom.
> > 
> > btw., Mutt does not go boom, i use it myself. It works just fine and 
> > notices new mails even on a noatime,nodiratime filesystem.
> 
> Configuration dependant, and also mutt and the shell will misreport 
> new mail with noatime on the mail spool. The shell should probably use 
> inotify of course but that change has to be made.

just to quote from this same email thread:

| I too use mutt and noatime,nodiratime everywhere (same 10 year-old 
| thinko), and the only side effect is that when I have a new mail, it 
| is reported in all of my xterms until I read it, clearly something I 
| can live with (and sometimes it's even desirable).
|
| In fact, mutt is pretty good at this. It updates atime and ctime 
| itself as soon as it opens the mbox, so the shell is happy and only 
| reports "you have mail" afterwards.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
