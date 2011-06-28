Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 97CF76B010A
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 05:11:38 -0400 (EDT)
Subject: Re: [patch]mm: __tlb_remove_page checks correct batch
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1309232767.15392.200.camel@sli10-conroe>
References: <1309232767.15392.200.camel@sli10-conroe>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 28 Jun 2011 11:10:42 +0200
Message-ID: <1309252242.6701.176.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Tue, 2011-06-28 at 11:46 +0800, Shaohua Li wrote:
> __tlb_remove_page switchs to a new batch page, but still checks space in =
the
> old batch. This check always fails, and causes force tlb flush.
>=20
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

Indeed!

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

> diff --git a/mm/memory.c b/mm/memory.c
> index 40b7531..9b8a01d 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -305,6 +305,7 @@ int __tlb_remove_page(struct mmu_gather *tlb, struct =
page *page)
>  	if (batch->nr =3D=3D batch->max) {
>  		if (!tlb_next_batch(tlb))
>  			return 0;
> +		batch =3D tlb->active;
>  	}
>  	VM_BUG_ON(batch->nr > batch->max);
> =20
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
