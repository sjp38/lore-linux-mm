Date: Sun, 5 Aug 2007 16:42:20 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [patch] implement smarter atime updates support, v2
Message-ID: <20070805204220.GB32217@thunk.org>
References: <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070805102021.GA4246@unthought.net> <46B5A996.5060006@garzik.org> <20070805105850.GC4246@unthought.net> <20070805124648.GA21173@elte.hu> <alpine.LFD.0.999.0708050944470.5037@woody.linux-foundation.org> <20070805190928.GA17433@elte.hu> <20070805192226.GA20234@elte.hu> <20070805192838.GA21704@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070805192838.GA21704@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jakob Oestergaard <jakob@unthought.net>, Jeff Garzik <jeff@garzik.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sun, Aug 05, 2007 at 09:28:38PM +0200, Ingo Molnar wrote:
> 
> added the relatime_interval sysctl that allows the changing of the atime 
> update frequency. (default: 1 day / 86400 seconds)

What if you specify the interval as a per-mount option?  i.e., 

	mount -o relatime=86400 /dev/sda2 /u1

If you had this, I don't think we would need the sysctl tuning parameter.

							- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
