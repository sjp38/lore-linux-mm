Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 7229B6B0087
	for <linux-mm@kvack.org>; Sat, 26 Nov 2011 13:53:24 -0500 (EST)
Date: Sat, 26 Nov 2011 18:33:15 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: migration: pair unlock_page and lock_page when
 migrating huge pages
Message-ID: <20111126173315.GG8397@redhat.com>
References: <CAJd=RBChfVC4hUKvO5ks0+NxahTgibdivLotw3VpAa7_-r8_+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBChfVC4hUKvO5ks0+NxahTgibdivLotw3VpAa7_-r8_+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi Hillf,

On Fri, Nov 25, 2011 at 08:20:31PM +0800, Hillf Danton wrote:
> Skip unlocking page if fail to lock, then lock and unlock are paired.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/migrate.c	Fri Nov 25 20:11:14 2011
> +++ b/mm/migrate.c	Fri Nov 25 20:21:26 2011
> @@ -869,9 +869,9 @@ static int unmap_and_move_huge_page(new_
> 
>  	if (anon_vma)
>  		put_anon_vma(anon_vma);
> -out:
>  	unlock_page(hpage);
> 
> +out:
>  	if (rc != -EAGAIN) {
>  		list_del(&hpage->lru);
>  		put_page(hpage);

Looks good, I guess that path wasn't exercised frequently because
there's no blocking I/O involvement with hugetlbfs.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
