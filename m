Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id D20E66B0068
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 08:33:53 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so4375542qcs.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 05:33:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
Date: Tue, 31 Jul 2012 08:33:52 -0400
Message-ID: <CA+5PVA4CE0kwD1FmV=081wfCObVYe5GFYBQFO9_kVL4JWJBqpA@mail.gmail.com>
Subject: Re: [PATCH 0/6][resend] mempolicy memory corruption fixlet
From: Josh Boyer <jwboyer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, Jun 11, 2012 at 5:17 AM,  <kosaki.motohiro@gmail.com> wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> Hi
>
> This is trivial fixes of mempolicy meory corruption issues. There
> are independent patches each ather. and, they don't change userland
> ABIs.
>
> Thanks.
>
> changes from v1: fix some typo of changelogs.
>
> -----------------------------------------------
> KOSAKI Motohiro (6):
>   Revert "mm: mempolicy: Let vma_merge and vma_split handle
>     vma->vm_policy linkages"
>   mempolicy: Kill all mempolicy sharing
>   mempolicy: fix a race in shared_policy_replace()
>   mempolicy: fix refcount leak in mpol_set_shared_policy()
>   mempolicy: fix a memory corruption by refcount imbalance in
>     alloc_pages_vma()
>   MAINTAINERS: Added MEMPOLICY entry
>
>  MAINTAINERS    |    7 +++
>  mm/mempolicy.c |  151 ++++++++++++++++++++++++++++++++++++++++----------------
>  mm/shmem.c     |    9 ++--
>  3 files changed, 120 insertions(+), 47 deletions(-)

I don't see these patches queued anywhere.  They aren't in linux-next,
mmotm, or Linus' tree.  Did these get dropped?  Is the revert still
needed?

josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
