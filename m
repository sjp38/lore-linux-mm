Date: Mon, 6 Aug 2007 08:57:12 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070806065712.GA2818@elte.hu>
References: <20070803123712.987126000@chello.nl> <46B4E161.9080100@garzik.org> <20070804224706.617500a0@the-village.bc.nu> <200708050051.40758.ctpm@ist.utl.pt> <20070805014926.400d0608@the-village.bc.nu> <20070805072805.GB4414@elte.hu> <20070805134640.2c7d1140@the-village.bc.nu> <20070805125847.GC22060@elte.hu> <20070805132925.GA4089@1wt.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070805132925.GA4089@1wt.eu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Claudio Martins <ctpm@ist.utl.pt>, Jeff Garzik <jeff@garzik.org>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Willy Tarreau <w@1wt.eu> wrote:

> In your example above, maybe it's the opposite, users know they can 
> keep a file in /tmp one more week by simply cat'ing it.

sure - and i'm not arguing that noatime should the kernel-wide default. 
In every single patch i sent it was a .config option (and a boot option 
_and_ a sysctl option that i think you missed) that a user/distro 
enables or disabled. But i think the /tmp argument is not very strong: 
/tmp is fundamentally volatile, and you can grow dependencies on pretty 
much _any_ aspect of the kernel. So the question isnt "is there impact" 
(there is, at least for noatime), the question is "is it still worth 
doing it".

> Changing the kernel in a non-easily reversible way is not kind to the 
> users.

none of my patches did any of that...

anyway, my latest patch doesnt do noatime, it does the "more intelligent 
relatime" approach.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
