Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BF5BB6B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:57:32 -0400 (EDT)
Date: Fri, 12 Jun 2009 12:07:16 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 4/5] HWPOISON: report sticky EIO for poisoned file
Message-ID: <20090612100716.GE25568@one.firstfloor.org>
References: <20090611142239.192891591@intel.com> <20090611144430.813191526@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090611144430.813191526@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 10:22:43PM +0800, Wu Fengguang wrote:
> This makes the EIO reports on write(), fsync(), or the NFS close()
> sticky enough. The only way to get rid of it may be
> 
> 	echo 3 > /proc/sys/vm/drop_caches
> 
> Note that the impacted process will only be killed if it mapped the page.
> XXX
> via read()/write()/fsync() instead of memory mapped reads/writes, simply
> because it's very hard to find them.

I don't like the special case bit. Conceptually we shouldn't need
to handle hwpoison specially here; it's just like a standard error. 

It makes hwpoison look more intrusive than it really is :)

I think it would be better to simply make
the standard EIO sticky; that would fix a lot of other issues too (e.g.
better reporting of metadata errors) But that's something for post .31.

For .31 I think hwpoison can live fine with non sticky errors; it was
more a problem of the test suite anyways which we worked around.

So better drop this patch for now.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
