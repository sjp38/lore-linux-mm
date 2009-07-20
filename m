Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 55D5A6B005D
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 11:09:40 -0400 (EDT)
Message-ID: <4A6488A1.4050800@redhat.com>
Date: Mon, 20 Jul 2009 11:09:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] ksm: define MADV_MERGEABLE and MADV_UNMERGEABLE
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com> <1247851850-4298-2-git-send-email-ieidus@redhat.com> <1247851850-4298-3-git-send-email-ieidus@redhat.com> <1247851850-4298-4-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-4-git-send-email-ieidus@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Michael Kerrisk <mtk.manpages@gmail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>, Chris Zankel <chris@zankel.net>
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
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
> 
> Based upon earlier patches by Chris Wright and Izik Eidus.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Signed-off-by: Chris Wright <chrisw@redhat.com>
> Signed-off-by: Izik Eidus <ieidus@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
