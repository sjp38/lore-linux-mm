From: Claudio Martins <ctpm@ist.utl.pt>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Date: Sun, 5 Aug 2007 00:51:40 +0100
References: <20070803123712.987126000@chello.nl> <46B4E161.9080100@garzik.org> <20070804224706.617500a0@the-village.bc.nu>
In-Reply-To: <20070804224706.617500a0@the-village.bc.nu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708050051.40758.ctpm@ist.utl.pt>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jeff Garzik <jeff@garzik.org>, Ingo Molnar <mingo@elte.hu>, =?iso-8859-1?q?J=F6rn_Engel?= <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Saturday 04 August 2007, Alan Cox wrote:
>
> Linux has never been a "suprise your kernel interfaces all just changed
> today" kernel, nor a "gosh you upgraded and didn't notice your backups
> broke" kernel.
>

 Can you give examples of backup solutions that rely on atime being updated?
I can understand backup tools using mtime/ctime for incremental backups (like 
tar + Amanda, etc), but I'm having trouble figuring out why someone would 
want to use atime for that.

 Best regards

Claudio

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
