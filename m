Date: Sun, 5 Aug 2007 01:49:26 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805014926.400d0608@the-village.bc.nu>
In-Reply-To: <200708050051.40758.ctpm@ist.utl.pt>
References: <20070803123712.987126000@chello.nl>
	<46B4E161.9080100@garzik.org>
	<20070804224706.617500a0@the-village.bc.nu>
	<200708050051.40758.ctpm@ist.utl.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Claudio Martins <ctpm@ist.utl.pt>
Cc: Jeff Garzik <jeff@garzik.org>, Ingo Molnar <mingo@elte.hu>, =?UTF-8?B?SsO2cm4=?= Engel <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

>  Can you give examples of backup solutions that rely on atime being updated?
> I can understand backup tools using mtime/ctime for incremental backups (like 
> tar + Amanda, etc), but I'm having trouble figuring out why someone would 
> want to use atime for that.

HSM is the usual one, and to a large extent probably why Unix originally
had atime. Basically migrating less used files away so as to keep the
system disks tidy.

Its not something usally found on desktop boxes so it doesn't in anyway
argue against the distribution using noatime or relative atime, but on
big server boxes it matters

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
