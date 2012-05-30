Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id EDDE66B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 15:46:27 -0400 (EDT)
Received: by yhr47 with SMTP id 47so233166yhr.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 12:46:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205301439410.31768@router.home>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
 <1338368529-21784-3-git-send-email-kosaki.motohiro@gmail.com> <alpine.DEB.2.00.1205301439410.31768@router.home>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 30 May 2012 15:46:05 -0400
Message-ID: <CAHGf_=pzxcr3Tvfip4a_fFX5xoAy00SNgKBOxGg65Ro9xAopwA@mail.gmail.com>
Subject: Re: [PATCH 2/6] mempolicy: Kill all mempolicy sharing
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, stable@vger.kernel.org, hughd@google.com, Andrew Morton <akpm@linux-foundation.org>, andi@firstfloor.org

On Wed, May 30, 2012 at 3:41 PM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 30 May 2012, kosaki.motohiro@gmail.com wrote:
>
>> refcount will be decreased even though was not increased whenever alloc_page_vma()
>> is called. As you know, mere mbind(MPOL_MF_MOVE) calls alloc_page_vma().
>
> Most of these issues are about memory migration and shared memory. If we
> exempt shared memory from memory migration (after all that shared memory
> has its own distinct memory policies already!) then a lot of these issues
> wont arise.

The final point is, to make proper cow for struct mempolicy. but until
fixing cpuset
bindings issue, we can't use mempolicy sharing anyway.

Moreover, now most core piece of mempolicy life cycle, say split_vma()
and dup_mmap(), don't use mempolicy sharing. Only mbind() does.

Thus, this patch don't increase normal workload memory usage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
