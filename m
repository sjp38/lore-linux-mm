Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF666B009A
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 17:53:38 -0500 (EST)
Date: Fri, 17 Dec 2010 14:53:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2010-12-16-14-56 uploaded (hugetlb)
Message-Id: <20101217145334.3d67d80b.akpm@linux-foundation.org>
In-Reply-To: <20101217143316.fa36be7d.randy.dunlap@oracle.com>
References: <201012162329.oBGNTdPY006808@imap1.linux-foundation.org>
	<20101217143316.fa36be7d.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Dec 2010 14:33:16 -0800
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> On Thu, 16 Dec 2010 14:56:39 -0800 akpm@linux-foundation.org wrote:
> 
> > The mm-of-the-moment snapshot 2010-12-16-14-56 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > and will soon be available at
> > 
> >    git://zen-kernel.org/kernel/mmotm.git
> > 
> > It contains the following patches against 2.6.37-rc6:
> 
> 
> # CONFIG_HUGETLBFS is not set
> CONFIG_HUGETLB_PAGE=y
> 
> 
> In file included from mmotm-2010-1216-1456/kernel/fork.c:36:
> mmotm-2010-1216-1456/include/linux/hugetlb.h: In function 'hstate_inode':
> mmotm-2010-1216-1456/include/linux/hugetlb.h:255: error: implicit declaration of function 'HUGETLBFS_SB'
> 

afacit, CONFIG_HUGETLBFS must be enabled if CONFIG_HUGETLB_PAGE=y, and
thp-config_transparent_hugepage.patch broke that, by permitting
CONFIG_HUGETLBFS=n, CONFIG_HUGETLB_PAGE=y,
CONFIG_TRANSPARENT_HUGEPAGE=y.

I suppose CONFIG_TRANSPARENT_HUGEPAGE could select CONFIG_HUGETLBFS,
but is there a nicer way?


There's lots of stuff in hugetlb.h which is clearly related to
hugetlbfs, but is enabled by CONFIG_HUGETLB_PAGE, so those things seem
to be pretty joined at the hip nowadays.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
