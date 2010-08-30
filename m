Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A11166B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 19:53:16 -0400 (EDT)
Received: by gxk9 with SMTP id 9so2880661gxk.14
        for <linux-mm@kvack.org>; Mon, 30 Aug 2010 16:53:17 -0700 (PDT)
Date: Tue, 31 Aug 2010 07:53:06 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100830235306.GA5202@localhost>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
 <20100819143710.GA4752@infradead.org>
 <1282229905.6199.19.camel@heimdal.trondhjem.org>
 <20100819151618.5f769dc9@tlielax.poochiereds.net>
 <1282246999.7799.66.camel@heimdal.trondhjem.org>
 <20100820132309.GB20126@localhost>
 <1283196174.2920.4.camel@heimdal.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1283196174.2920.4.camel@heimdal.trondhjem.org>
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Jeff Layton <jlayton@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 30, 2010 at 03:22:54PM -0400, Trond Myklebust wrote:
> On Fri, 2010-08-20 at 21:23 +0800, Wu Fengguang wrote:
> > > > Here's a lightly tested patch that turns the check for the two flags
> > > > into a check for WB_SYNC_NONE. It seems to do the right thing, but I
> > > > don't have a clear testcase for it. Does this look reasonable?
> > > 
> > > Looks fine to me. I'll queue it up for the post-2.6.36 merge window...
> > 
> > Trond, I just created a patch that removes the wbc->nonblocking
> > definition and all its references except NFS. So there will be merge
> > dependencies. What should we do?  To push both patches to Andrew's -mm
> > tree?
> > 
> > Thanks,
> > Fengguang
> 
> Do you want to include it as part of your series? Just remember to add
> an
> 
> Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Thanks. Please keep the NFS patches in your tree. I've send a patch
to Andrew Morton which removes the other references but keeps the
definitions. So that there won't be compile errors when the patches
are pushed at different time.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
