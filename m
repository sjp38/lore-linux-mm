Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4J0RQ0c162378
	for <linux-mm@kvack.org>; Wed, 18 May 2005 20:27:26 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4J0RP1o184650
	for <linux-mm@kvack.org>; Wed, 18 May 2005 18:27:25 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4J0RPjj013089
	for <linux-mm@kvack.org>; Wed, 18 May 2005 18:27:25 -0600
Subject: Re: page flags ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20050518162302.13a13356.akpm@osdl.org>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>
	 <20050518145644.717afc21.akpm@osdl.org>
	 <1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com>
	 <20050518162302.13a13356.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1116461369.26913.1339.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 18 May 2005 17:09:29 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-05-18 at 16:23, Andrew Morton wrote:
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> >
> > Is it possible to get yet another PG_fs_specific flag ? 
> 
> Anything's possible ;)
> 
> How many bits are spare now?  ZONETABLE_PGSHIFT hurts my brain.

Depends on whom you ask :) CKRM folks are using one/few, 
Hotplug memory guys are using one... :( I lost track..

> 
> > Reasons for it are:
> > 
> > 	- I need this for supporting delayed allocation on ext3.
> 
> Why?
> 

I think, I explained you earlier.. But let me refresh your memory.


In order to do delayed allocation, we "reserve" (not same reservation
the code) a block in prepare/commit and do the allocation in
writepage/writepages.  Unfortunately, mapped writes directly come into
writepage without making a reservation. In order to guarantee that
write() succeeds, I need a way to indicate if the "page" has made
a reservation or not. I was hoping to use a page->flag to do this.
That way I don't have to touch page->private like Alex's code and
get away using mpage routines, instead of having my own.


Thanks,
Badari


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
