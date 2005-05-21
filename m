Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4L0HvU5007578
	for <linux-mm@kvack.org>; Fri, 20 May 2005 20:17:57 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4L0HvYV074508
	for <linux-mm@kvack.org>; Fri, 20 May 2005 20:17:57 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4L0HvYF015358
	for <linux-mm@kvack.org>; Fri, 20 May 2005 20:17:57 -0400
Date: Fri, 20 May 2005 17:11:18 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: [PATCH 0/6] CKRM: Memory controller for CKRM
Message-ID: <20050521001118.GB30327@chandralinux.beaverton.ibm.com>
References: <20050519003008.GC25076@chandralinux.beaverton.ibm.com> <20050520.182624.67793132.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050520.182624.67793132.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 20, 2005 at 06:26:24PM +0900, Hirokazu Takahashi wrote:
> Hi Chandra,
> 
> 
> I think it's very heavy to move all pages, which are mapped to removing
> regions, to new classes every time. It always happens when doing exec()
> or exit(), while munmap and closing file don't.
> Pages associating with libc.so or text of shells might move around
> the all classes.
> 
> IMHO, it would be enough to just leave them as they are.
> These pages would be released a little later if no class touch them,
> or they might be accessed from another class to migrate another
> class, or they might reused in the same class.

No, it will be incorrect, as the class that is using the page doesn't need
these pages anymore, we should not be charging them for those pages.

May be we should do something light while keeping the accounting proper.
Any ideas ?
> 
> I feel it's not needed to move these pages in hurry.
> I prefer the implementation light.
> What do you think?
> 
> 
> BTW, the memory controller would be a good new to video streaming
> guys, I guess.
> 
> 
> Thanks,
> Hirokazu Takahashi.
> 

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
