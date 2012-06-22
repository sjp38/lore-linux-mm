Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id C6EED6B015D
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 05:58:53 -0400 (EDT)
Message-ID: <1340359115.18025.57.camel@twins>
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 22 Jun 2012 11:58:35 +0200
In-Reply-To: <1340315835-28571-2-git-send-email-riel@surriel.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
	 <1340315835-28571-2-git-send-email-riel@surriel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Thu, 2012-06-21 at 17:57 -0400, Rik van Riel wrote:
> @@ -1941,6 +2017,8 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, st=
ruct vm_area_struct *vma,
>         *insertion_point =3D vma;
>         if (vma)
>                 vma->vm_prev =3D prev;
> +       if (vma)
> +               rb_augment_erase_end(&vma->vm_rb, vma_rb_augment_cb, NULL=
);=20

Shouldn't that be adjust_free_gap()? There is after all no actual erase
happening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
