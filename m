Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id BA1386B0141
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 10:43:41 -0400 (EDT)
Date: Mon, 11 Jun 2012 09:43:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/6] Revert "mm: mempolicy: Let vma_merge and vma_split
 handle vma->vm_policy linkages"
In-Reply-To: <1339406250-10169-2-git-send-email-kosaki.motohiro@gmail.com>
Message-ID: <alpine.DEB.2.00.1206110935070.31180@router.home>
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com> <1339406250-10169-2-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, 11 Jun 2012, kosaki.motohiro@gmail.com wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
>
> commit 05f144a0d5 "mm: mempolicy: Let vma_merge and vma_split handle
> vma->vm_policy linkages" removed a vma->vm_policy updates. But it is
> a primary purpose of mbind_range(). Now, mbind(2) is no-op in several
> case unintentionally. It is not ideal fix. This patch reverts it.

Rewritten changelog:

commit 05f144a0d5 "mm: mempolicy: Let vma_merge and vma_split handle
vma->vm_policy linkages" removed policy_vma() but the function is
needed in this patchset.


(It is not clear to me what the last sentences mean. AFAICT the code for
policy_vma() still exists in another function prior to this patch)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
