Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1F22F6B0055
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 11:44:22 -0400 (EDT)
Date: Mon, 20 Jul 2009 16:44:30 +0100
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 03/10] ksm: define MADV_MERGEABLE and MADV_UNMERGEABLE
Message-ID: <20090720154430.GE16361@linux-mips.org>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com> <1247851850-4298-2-git-send-email-ieidus@redhat.com> <1247851850-4298-3-git-send-email-ieidus@redhat.com> <1247851850-4298-4-git-send-email-ieidus@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1247851850-4298-4-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Michael Kerrisk <mtk.manpages@gmail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>, Chris Zankel <chris@zankel.net>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 17, 2009 at 08:30:43PM +0300, Izik Eidus wrote:

> From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> The out-of-tree KSM used ioctls on fds cloned from /dev/ksm to register
> a memory area for merging: we prefer now to use an madvise(2) interface.
> 
> This patch just defines MADV_MERGEABLE (to tell KSM it may merge pages
> in this area found identical to pages in other mergeable areas) and
> MADV_UNMERGEABLE (to undo that).
> 
> Most architectures use asm-generic, but alpha, mips, parisc, xtensa
> need their own definitions: included here for mmotm convenience, but
> we'll probably want to split this and feed pieces to arch maintainers.

I think it's ok to keep these patches combined as a single patch; we'd
normally want them to be applied either all or not at all anyway and if
that's all the arch dependencies KSM has then splitting really just
unnecessarily inflates the number of patches.

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
