Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D0AFC6B0047
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 18:56:16 -0500 (EST)
Date: Wed, 3 Feb 2010 15:47:24 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 0/4] devmem and readahead fixes for 2.6.33
Message-ID: <20100203234724.GA23902@kroah.com>
References: <20100122045914.993668874@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100122045914.993668874@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, linux-fsdevel@vger.kernel.org, stable@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 22, 2010 at 12:59:14PM +0800, Wu Fengguang wrote:
> Greg,
> 
> The first two patches are on devmem. 2.6.32 also needs fixing, however
> the patches can only apply cleanly to 2.6.33. I can do backporting if
> necessary.
> 
> 	[PATCH 1/4] devmem: check vmalloc address on kmem read/write
> 	[PATCH 2/4] devmem: fix kmem write bug on memory holes

As these patches are now in Linus's tree, can you provide backports for
them and send them to the stable@kernel.org address?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
