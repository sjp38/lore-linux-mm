Date: Sun, 5 Aug 2007 19:55:47 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805175547.GC3244@elte.hu>
References: <20070803123712.987126000@chello.nl> <46B4E161.9080100@garzik.org> <20070804224706.617500a0@the-village.bc.nu> <200708050051.40758.ctpm@ist.utl.pt> <20070805014926.400d0608@the-village.bc.nu> <20070805144645.GA28263@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070805144645.GA28263@thunk.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Claudio Martins <ctpm@ist.utl.pt>, Jeff Garzik <jeff@garzik.org>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Theodore Tso <tytso@mit.edu> wrote:

> If you are always reading from the same small set of files (i.e., a 
> database workload), then those inodes only get updated every 5 seconds 
> (the traditional/default metadata update sync time, as well as the 
> default ext3 journal update time), it's no big deal.  Or if you are 
> running a mail server, most of the time the mail queue files are 
> getting updated anyway as you process them, and usually the mail is 
> delivered before 5 seconds is up anyway.
> 
> So earlier, when Ingo characterized it as, "whenever you read from a 
> file, even one in memory cache.... do a write!", it's probably a bit 
> unfair.  Traditional Unix systems simply had very different workload 
> characteristics than many modern dekstop systems today.

yeah, i didnt mean to say that it is _always_ a big issue, but "only a 
small number of files are read" is a very, very small minority of even 
the database server world.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
