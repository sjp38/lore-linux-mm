Date: Sun, 5 Aug 2007 12:58:50 +0200
From: Jakob Oestergaard <jakob@unthought.net>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805105850.GC4246@unthought.net>
References: <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org> <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070805102021.GA4246@unthought.net> <46B5A996.5060006@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46B5A996.5060006@garzik.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sun, Aug 05, 2007 at 06:42:30AM -0400, Jeff Garzik wrote:
...
> If you can show massive amounts of users that will actually be 
> negatively impacted, please present hard evidence.
> 
> Otherwise all this is useless hot air.

Peace Jeff  :)

In another mail, I gave an example with tmpreaper clearing out unused
files; if some of those files are only read and never modified,
tmpreaper would start deleting files which were still frequently used.

That's a regression, the way I see it. As for 'massive amounts of
users', well, tmpreaper exists in most distros, so it's possible it has
other users than just me.

-- 

 / jakob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
