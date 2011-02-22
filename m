Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F1F5D8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 10:34:37 -0500 (EST)
Date: Tue, 22 Feb 2011 09:34:33 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/8] Fix interleaving for transparent hugepages
In-Reply-To: <1298315270-10434-2-git-send-email-andi@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1102220933500.16060@router.home>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org> <1298315270-10434-2-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>


On Mon, 21 Feb 2011, Andi Kleen wrote:

> @@ -1830,7 +1830,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
>  		unsigned nid;
>
> -		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
> +		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT << order);

Should be PAGE_SHIFT + order.
x

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
