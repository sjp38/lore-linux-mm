Date: Sun, 5 Aug 2007 15:46:45 +0200
From: Jakob Oestergaard <jakob@unthought.net>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805134645.GD4246@unthought.net>
References: <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070805102021.GA4246@unthought.net> <46B5A996.5060006@garzik.org> <20070805105850.GC4246@unthought.net> <20070805124648.GA21173@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070805124648.GA21173@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sun, Aug 05, 2007 at 02:46:48PM +0200, Ingo Molnar wrote:
> 
> * Jakob Oestergaard <jakob@unthought.net> wrote:
> 
> > > If you can show massive amounts of users that will actually be 
> > > negatively impacted, please present hard evidence.
> > > 
> > > Otherwise all this is useless hot air.
> > 
> > Peace Jeff :)
> > 
> > In another mail, I gave an example with tmpreaper clearing out unused 
> > files; if some of those files are only read and never modified, 
> > tmpreaper would start deleting files which were still frequently used.
> > 
> > That's a regression, the way I see it. As for 'massive amounts of 
> > users', well, tmpreaper exists in most distros, so it's possible it 
> > has other users than just me.
> 
> you mean tmpwatch?

Same same.

> The trivial change below fixes this. And with that 
> we've come to the end of an extremely short list of atime dependencies.

Please read what I wrote, not what you think I wrote.

If I only *read* those files, the mtime will not be updated, only the
atime.

And the files *will* then magically begin to disappear although they are
frequently used.

That will happen with a standard piece of software in a standard
configuration, in a scenario that may or may not be common... I have no
idea how common such a setup is - but I know how much it would suck to
have files magically disappearing because of a kernel upgrade  :)

-- 

 / jakob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
