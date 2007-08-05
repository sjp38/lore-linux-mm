Date: Sun, 5 Aug 2007 20:09:41 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805180941.GE3244@elte.hu>
References: <20070803123712.987126000@chello.nl> <46B4E161.9080100@garzik.org> <20070804224706.617500a0@the-village.bc.nu> <200708050051.40758.ctpm@ist.utl.pt> <20070805014926.400d0608@the-village.bc.nu> <20070805144645.GA28263@thunk.org> <20070805175547.GC3244@elte.hu> <46B60FFC.2000909@garzik.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46B60FFC.2000909@garzik.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Theodore Tso <tytso@mit.edu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Claudio Martins <ctpm@ist.utl.pt>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Jeff Garzik <jeff@garzik.org> wrote:

> > yeah, i didnt mean to say that it is _always_ a big issue, but "only 
> > a small number of files are read" is a very, very small minority of 
> > even the database server world.
> 
> OTOH, consider a popular Linux task, web serving.  atime results in a 
> lot of unnecessary disk traffic.

it's a big, noticeable effect on 99% of the Linux boxes.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
