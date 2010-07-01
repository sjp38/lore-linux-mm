Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 79DB16B01AC
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 04:44:09 -0400 (EDT)
Subject: Re: [patch] mm: vmap area cache
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <20100630162602.874ebd2a.akpm@linux-foundation.org>
References: <20100531080757.GE9453@laptop>
	 <20100602144905.aa613dec.akpm@linux-foundation.org>
	 <20100603135533.GO6822@laptop>
	 <1277470817.3158.386.camel@localhost.localdomain>
	 <20100626083122.GE29809@laptop>
	 <20100630162602.874ebd2a.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 01 Jul 2010 09:49:14 +0100
Message-ID: <1277974154.2477.3.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, "Barry J. Marson" <bmarson@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 2010-06-30 at 16:26 -0700, Andrew Morton wrote:
> On Sat, 26 Jun 2010 18:31:22 +1000
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > On Fri, Jun 25, 2010 at 02:00:17PM +0100, Steven Whitehouse wrote:
> > > Hi,
> > > 
> > > Barry Marson has now tested your patch and it seems to work just fine.
> > > Sorry for the delay,
> > > 
> > > Steve.
> > 
> > Hi Steve,
> > 
> > Thanks for that, do you mean that it has solved thee regression?
> 
> Nick, can we please have an updated changelog for this patch?  I didn't
> even know it fixed a regression (what regression?).  Barry's tested-by:
> would be nice too, along with any quantitative results from that.
> 
> Thanks.

Barry is running a benchmark test against GFS2 which simulates NFS
activity on the filesystem. Without this patch, the GFS2 ->readdir()
function (the only part of GFS2 which uses vmalloc) runs so slowly that
the test does not complete. With the patch, the test runs the same speed
as it did on earlier kernels.

I don't have an exact pointer to when the regression was introduced, but
it was after RHEL5 branched.

I've cc'd Barry so that he can add his Tested-By: if he is happy to do
so,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
