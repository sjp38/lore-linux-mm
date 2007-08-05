Date: Mon, 6 Aug 2007 09:43:56 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805234356.GI31489@sgi.com>
References: <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org> <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070805102021.GA4246@unthought.net> <46B5A996.5060006@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46B5A996.5060006@garzik.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Jakob Oestergaard <jakob@unthought.net>, Linus Torvalds <torvalds@linux-foundation.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sun, Aug 05, 2007 at 06:42:30AM -0400, Jeff Garzik wrote:
> Jakob Oestergaard wrote:
> >Oh dear.
> >
> >Why not just make ext3 fsync() a no-op while you're at it?
> >
> >Distros can turn it back on if it's needed...
> >
> >Of course I'm not serious, but like atime, fsync() is something one
> 
> No, they are nothing alike, and you are just making yourself look silly 
> if you compare them.  fsync has to do with fundamental guarantees about 
> data.

Hi Jeff - just as a point to note, I think you should check the spec
for fsync before stating that:

"It is explicitly intended that a null implementation is permitted."

and

"... fsync() might or might not actually cause data to be written where it is
safe from a power failure."

http://www.opengroup.org/onlinepubs/009695399/functions/fsync.html

So fsync() does not have to provide the fundamental guarantees you think
it should.

Note - I'm not saying that this is at all sane (it's crazy, IMO), I'm just
pointing out that a "nofsync" mount option to avoid fsync overhead is a
legal thing to do....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
