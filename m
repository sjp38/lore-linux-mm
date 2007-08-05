Date: Sun, 5 Aug 2007 13:46:40 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805134640.2c7d1140@the-village.bc.nu>
In-Reply-To: <20070805072805.GB4414@elte.hu>
References: <20070803123712.987126000@chello.nl>
	<46B4E161.9080100@garzik.org>
	<20070804224706.617500a0@the-village.bc.nu>
	<200708050051.40758.ctpm@ist.utl.pt>
	<20070805014926.400d0608@the-village.bc.nu>
	<20070805072805.GB4414@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Claudio Martins <ctpm@ist.utl.pt>, Jeff Garzik <jeff@garzik.org>, =?UTF-8?B?SsO2cm4=?= Engel <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

> The only remotely valid compatibility argument would be Mutt - but even 
> that handles it just fine. (we broke way more software via noexec)

And went through a sensible process of resolving it.

And its not just mutt. HSM stuff stops working which is a big deal as
stuff clogs up. The /tmp/ cleaning tools go wrong as well.

These are big deals because you seem intent on using a large hammer to
force a change that should be done properly by other means.

The /tmp cleaning for example can probably be done other ways in future
but the changes should be in place first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
