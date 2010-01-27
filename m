Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAE36B0095
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 20:48:30 -0500 (EST)
Date: Tue, 26 Jan 2010 17:39:13 -0800
From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 0/4] devmem and readahead fixes for 2.6.33
Message-ID: <20100127013913.GA926@suse.de>
References: <20100122045914.993668874@intel.com>
 <20100122053157.GA8312@suse.de>
 <20100126165050.6ab7977b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100126165050.6ab7977b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, stable@kernel.org, Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 04:50:50PM -0800, Andrew Morton wrote:
> On Thu, 21 Jan 2010 21:31:57 -0800
> Greg KH <gregkh@suse.de> wrote:
> 
> > On Fri, Jan 22, 2010 at 12:59:14PM +0800, Wu Fengguang wrote:
> > > Andrew,
> > > 
> > > Here are some good fixes for 2.6.33, they have been floating around
> > > with other patches for some time. I should really seperate them out
> > > earlier..
> > > 
> > > Greg,
> > > 
> > > The first two patches are on devmem. 2.6.32 also needs fixing, however
> > > the patches can only apply cleanly to 2.6.33. I can do backporting if
> > > necessary.
> > > 
> > > 	[PATCH 1/4] devmem: check vmalloc address on kmem read/write
> > > 	[PATCH 2/4] devmem: fix kmem write bug on memory holes
> > 
> > After these hit Linus's tree, please send the backport to
> > stable@kernel.org and I will be glad to queue them up.
> > 
> 
> I tagged the first two patches for -stable and shall send them in for 2.6.33.
> 
> The second two patches aren't quite as obvious - perhaps a risk of
> weird regressions.  So I'm thinking I'll send them in for 2.6.34-rc1
> and I tagged them as "[2.6.33.x]" for -stable, so you can feed them
> into 2.6.33.x once 2.6.34-rcX has had a bit of testing time, OK?

Sounds good to me.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
