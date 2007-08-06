Date: Mon, 6 Aug 2007 07:36:17 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] implement smarter atime updates support, v2
Message-ID: <20070806053617.GB14881@elte.hu>
References: <46B4C0A8.1000902@garzik.org> <20070805102021.GA4246@unthought.net> <46B5A996.5060006@garzik.org> <20070805105850.GC4246@unthought.net> <20070805124648.GA21173@elte.hu> <alpine.LFD.0.999.0708050944470.5037@woody.linux-foundation.org> <20070805190928.GA17433@elte.hu> <20070805192226.GA20234@elte.hu> <20070805192838.GA21704@elte.hu> <20070805204220.GB32217@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070805204220.GB32217@thunk.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>, Linus Torvalds <torvalds@linux-foundation.org>, Jakob Oestergaard <jakob@unthought.net>, Jeff Garzik <jeff@garzik.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Theodore Tso <tytso@mit.edu> wrote:

> On Sun, Aug 05, 2007 at 09:28:38PM +0200, Ingo Molnar wrote:
> > 
> > added the relatime_interval sysctl that allows the changing of the 
> > atime update frequency. (default: 1 day / 86400 seconds)
> 
> What if you specify the interval as a per-mount option?  i.e.,
> 
> 	mount -o relatime=86400 /dev/sda2 /u1
> 
> If you had this, I don't think we would need the sysctl tuning 
> parameter.

it's much more flexible if there are _more_ options available. People 
can thus make use of the feature earlier, use it even on distros that 
dont support it yet, etc.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
