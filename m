Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D197B6B004F
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 09:34:46 -0400 (EDT)
Date: Tue, 1 Sep 2009 14:34:09 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/3] Add MAP_HUGETLB for mmaping pseudo-anonymous huge
 page regions
In-Reply-To: <20090901130801.GB7995@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0909011418490.8674@sister.anvils>
References: <cover.1251282769.git.ebmunson@us.ibm.com>
 <1c66a9e98a73d61c611e5cf09b276e954965046e.1251282769.git.ebmunson@us.ibm.com>
 <1721a3e8bdf8f311d2388951ec65a24d37b513b1.1251282769.git.ebmunson@us.ibm.com>
 <Pine.LNX.4.64.0908312036410.16402@sister.anvils> <20090901094635.GA7995@us.ibm.com>
 <Pine.LNX.4.64.0909011128530.16601@sister.anvils> <20090901130801.GB7995@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: Arnd Bergman <arnd@arndb.de>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-man@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>

On Tue, 1 Sep 2009, Eric B Munson wrote:
> On Tue, 01 Sep 2009, Hugh Dickins wrote:
> > 
> > That is explained by you #defining MAP_HUGETLB in include/asm-generic/
> > mman-common.h to a number which is already being used for other MAP_s
> > on some architectures.  That's a separate bug which needs to be fixed
> > by distributing the MAP_HUGETLB definition across various asm*/mman.h.
> 
> Would it be okay to keep the define in include/asm-generic/mman.h
> if a value that is known free across all architectures is used?
> 0x080000 is not used by any arch and, AFAICT would work just as well.

That's a very sensible suggestion, but departs from how we have
assigned new numbers up until now: so include/asm-generic/mman-common.h
isn't actually where we'd expect to find a Linux-specific MAP_ define.

I'd say, yes, do that for now, so as not to hit this conflict while
testing in mmotm.  But whether it should stay that way, or later the
arch/*/include/asm/mman.h's be updated as I'd imagined, I don't know.

Arnd, Michael, do you have any views on this?

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
