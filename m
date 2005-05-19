Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4J0Wndv024883
	for <linux-mm@kvack.org>; Wed, 18 May 2005 20:32:49 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4J0Wnkv121532
	for <linux-mm@kvack.org>; Wed, 18 May 2005 20:32:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4J0WmT0031288
	for <linux-mm@kvack.org>; Wed, 18 May 2005 20:32:48 -0400
Date: Wed, 18 May 2005 17:26:36 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: page flags ?
Message-ID: <20050519002636.GB25076@chandralinux.beaverton.ibm.com>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com> <20050518145644.717afc21.akpm@osdl.org> <1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com> <20050518162302.13a13356.akpm@osdl.org> <1116461369.26913.1339.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1116461369.26913.1339.camel@dyn318077bld.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 18, 2005 at 05:09:29PM -0700, Badari Pulavarty wrote:
> On Wed, 2005-05-18 at 16:23, Andrew Morton wrote:
> > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > >
> > > Is it possible to get yet another PG_fs_specific flag ? 
> > 
> > Anything's possible ;)
> > 
> > How many bits are spare now?  ZONETABLE_PGSHIFT hurts my brain.
> 
> Depends on whom you ask :) CKRM folks are using one/few, 

CKRM used one bit... getting rid of it..

> Hotplug memory guys are using one... :( I lost track..
> 
> > 
> > > Reasons for it are:
> > > 
> > > 	- I need this for supporting delayed allocation on ext3.
> > 
> > Why?
> > 
> 
> I think, I explained you earlier.. But let me refresh your memory.
> 
> 
> In order to do delayed allocation, we "reserve" (not same reservation
> the code) a block in prepare/commit and do the allocation in
> writepage/writepages.  Unfortunately, mapped writes directly come into
> writepage without making a reservation. In order to guarantee that
> write() succeeds, I need a way to indicate if the "page" has made
> a reservation or not. I was hoping to use a page->flag to do this.
> That way I don't have to touch page->private like Alex's code and
> get away using mpage routines, instead of having my own.
> 
> 
> Thanks,
> Badari
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
