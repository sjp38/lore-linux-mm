Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id C821F6B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 09:35:36 -0400 (EDT)
Date: Mon, 22 Oct 2012 15:35:34 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v6
Message-ID: <20121022133534.GR16230@one.firstfloor.org>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org> <CAHO5Pa0W-WGBaPvzdRJxYPdrg-K9guChswo3KJheK4BaRzsRwQ@mail.gmail.com> <20121022132733.GQ16230@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121022132733.GQ16230@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Hillf Danton <dhillf@gmail.com>

On Mon, Oct 22, 2012 at 03:27:33PM +0200, Andi Kleen wrote:
> > Maybe I am missing something obvious, but does this not conflict with
> > include/uapi/asm-generic/mman-common.h:
> > 
> > #ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
> > # define MAP_UNINITIALIZED 0x4000000
> > ...
> > 
> > 0x4000000 == (1 << 26
> > 
> 
> You're right. Someone added that since I wrote the patch originally.
> I owned them when originally submitted @) Thanks for catching.
> 
> Have to move my bits two up, which will still work, but limit the

Two up won't work, need one up.  

32..28 = 16  is too small for 2^30 = 1GB pages
32..27 = 32  max 4GB pages

So this will use up all remaining flag bits now.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
