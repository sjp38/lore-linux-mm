Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5B7316B00B7
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 07:02:20 -0400 (EDT)
Message-ID: <1340276491.21745.170.camel@twins>
Subject: Re: [PATCH -mm 1/7] mm: track free size between VMAs in VMA rbtree
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 21 Jun 2012 13:01:31 +0200
In-Reply-To: <1340057126-31143-2-git-send-email-riel@redhat.com>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
	 <1340057126-31143-2-git-send-email-riel@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On Mon, 2012-06-18 at 18:05 -0400, Rik van Riel wrote:
> +static void adjust_free_gap(struct vm_area_struct *vma)
> +{
> +       rb_augment_erase_end(&vma->vm_rb, vma_rb_augment_cb, NULL);
> +}=20

This is a somewhat unorthodox usage of the rb_augment_erase_end()
function, at the very least that wants a comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
