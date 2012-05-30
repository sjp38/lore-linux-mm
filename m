Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 3DF9B6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 16:06:05 -0400 (EDT)
Date: Wed, 30 May 2012 14:44:14 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/6] Revert "mm: mempolicy: Let vma_merge and vma_split
 handle vma->vm_policy linkages"
In-Reply-To: <CAHGf_=oLsK2bk_ym6EZfFD=uRpr33CL+1=nWmf4hrnCxUOFisQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205301443020.31768@router.home>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com> <1338368529-21784-2-git-send-email-kosaki.motohiro@gmail.com> <alpine.DEB.2.00.1205301414020.31768@router.home> <CAHGf_=oLsK2bk_ym6EZfFD=uRpr33CL+1=nWmf4hrnCxUOFisQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, stable@vger.kernel.org, hughd@google.com, Andrew Morton <akpm@linux-foundation.org>

On Wed, 30 May 2012, KOSAKI Motohiro wrote:

> > You are dropping the nice comments by Mel that explain the refcounting.
>
> Because this is not strictly correct. 1) vma_merge() and split_vma() don't
> care mempolicy refcount. They only dup and drop it. 2) This mpol_get() is
> for vma attaching. This function don't need to care sp_node internal.

Ok then say so in the changelog.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
