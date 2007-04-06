Subject: Re: [PATCH 02/12] mm: scalable bdi statistics counters.
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070405153746.3cdb9bcd.akpm@linux-foundation.org>
References: <20070405174209.498059336@programming.kicks-ass.net>
	 <20070405174317.854739299@programming.kicks-ass.net>
	 <20070405153746.3cdb9bcd.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 06 Apr 2007 09:22:19 +0200
Message-Id: <1175844139.6483.133.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-04-05 at 15:37 -0700, Andrew Morton wrote:
> On Thu, 05 Apr 2007 19:42:11 +0200
> root@programming.kicks-ass.net wrote:
> 
> > Provide scalable per backing_dev_info statistics counters modeled on the ZVC
> > code.
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > ---
> >  block/ll_rw_blk.c           |    1 
> >  drivers/block/rd.c          |    2 
> >  drivers/char/mem.c          |    2 
> >  fs/char_dev.c               |    1 
> >  fs/fuse/inode.c             |    1 
> >  fs/nfs/client.c             |    1 
> >  include/linux/backing-dev.h |   98 +++++++++++++++++++++++++++++++++++++++++
> >  mm/backing-dev.c            |  103 ++++++++++++++++++++++++++++++++++++++++++++
> 
> madness!  Quite duplicative of vmstat.h, yet all this infrastructure
> is still only usable in one specific application.
> 
> Can we please look at generalising the vmstat.h stuff?
> 
> Or, the API in percpu_counter.h appears suitable to this application.
> (The comment at line 6 is a total lie).

Ok, I'll see what I can come up with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
