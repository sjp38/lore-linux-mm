Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 7A0C06B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 05:04:23 -0400 (EDT)
Received: by qabg27 with SMTP id g27so2120337qab.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 02:04:22 -0700 (PDT)
Message-ID: <4FC5E293.5060608@gmail.com>
Date: Wed, 30 May 2012 05:04:19 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: This is mistake message
References: <1338367958-21442-1-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <1338367958-21442-1-git-send-email-kosaki.motohiro@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, hughd@google.com, kosaki.motohiro@gmail.com

(5/30/12 4:52 AM), kosaki.motohiro@gmail.com wrote:
> KOSAKI Motohiro (6):
>    Revert "mm: mempolicy: Let vma_merge and vma_split handle
>      vma->vm_policy linkages"
>    mempolicy: Kill all mempolicy sharing
>    mempolicy: fix a race in shared_policy_replace()
>    mempolicy: fix refcount leak in mpol_set_shared_policy()
>    mempolicy: fix a memory corruption by refcount imbalance in
>      alloc_pages_vma()
>    MAINTAINERS: Added MEMPOLICY entry
> 
>   MAINTAINERS    |    7 +++
>   mm/mempolicy.c |  151 ++++++++++++++++++++++++++++++++++++++++----------------
>   mm/shmem.c     |    9 ++--
>   3 files changed, 120 insertions(+), 47 deletions(-)

Oh my good. My script sent garbage text. I'm sorry. Please trash this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
