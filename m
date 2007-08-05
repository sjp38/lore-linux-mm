Date: Sun, 5 Aug 2007 12:20:21 +0200
From: Jakob Oestergaard <jakob@unthought.net>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805102021.GA4246@unthought.net>
References: <20070803123712.987126000@chello.nl> <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org> <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46B4C0A8.1000902@garzik.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sat, Aug 04, 2007 at 02:08:40PM -0400, Jeff Garzik wrote:
> Linus Torvalds wrote:
> >The "relatime" thing that David mentioned might well be very useful, but 
> >it's probably even less used than "noatime" is. And sadly, I don't really 
> >see that changing (unless we were to actually change the defaults inside 
> >the kernel).
> 
> 
> I actually vote for that.  IMO, distros should turn -on- atime updates 
> when they know its needed.

Oh dear.

Why not just make ext3 fsync() a no-op while you're at it?

Distros can turn it back on if it's needed...

Of course I'm not serious, but like atime, fsync() is something one
expects to work if it's there.  Disabling atime updates or making
fsync() a no-op will both result in silent failure which I am sure we
can agree is disasterous.

Why on earth would you cripple the kernel defaults for ext3 (which is a
fine FS for boot/root filesystems), when the *fundamental* problem you
really want to solve lie much deeper in the implementation of the
filesystem?  Noatime doesn't solve the problem, it just makes it "less
horrible".

If you really need different filesystem performance characteristics, you
can switch to another filesystem. There's plenty to choose from.

-- 

 / jakob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
