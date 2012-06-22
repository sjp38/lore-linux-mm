Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E40646B015B
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 05:58:06 -0400 (EDT)
Message-ID: <1340359079.18025.56.camel@twins>
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 22 Jun 2012 11:57:59 +0200
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
> +/*
> + * Use the augmented rbtree code to propagate info on the largest
> + * free gap between VMAs up the VMA rbtree.
> + */
> +static void adjust_free_gap(struct vm_area_struct *vma)
> +{
> +       rb_augment_erase_end(&vma->vm_rb, vma_rb_augment_cb, NULL);
> +}=20

I was more thinking along the lines of:

/*
 * Abuse rb_augment_erase_end() to propagate a modification up
 * the tree by pretending the modified node is the deepest node
 * still in the tree.
 */


Alternatively, we could add rb_augment_mod() or somesuch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
