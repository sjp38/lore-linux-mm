Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7251D6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 05:00:21 -0400 (EDT)
Subject: Re: [PATCH 1/2] mm: convert k{un}map_atomic(p, KM_type) to
 k{un}map_atomic(p)
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 26 Aug 2011 10:59:56 +0200
In-Reply-To: <1314346676.6486.25.camel@minggr.sh.intel.com>
References: <1314346676.6486.25.camel@minggr.sh.intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314349196.26922.22.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Ming <ming.m.lin@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org

On Fri, 2011-08-26 at 16:17 +0800, Lin Ming wrote:
> @@ -292,7 +292,7 @@ static unsigned int bm_bit_to_page_idx(struct drbd_bi=
tmap *b, u64 bitnr)
>  static unsigned long *__bm_map_pidx(struct drbd_bitmap *b, unsigned int =
idx, const enum km_type km)
>  {
>         struct page *page =3D b->bm_pages[idx];
> -       return (unsigned long *) kmap_atomic(page, km);
> +       return (unsigned long *) kmap_atomic(page);
>  }
> =20
>  static unsigned long *bm_map_pidx(struct drbd_bitmap *b, unsigned int id=
x)
> @@ -302,7 +302,7 @@ static unsigned long *bm_map_pidx(struct drbd_bitmap =
*b, unsigned int idx)
> =20
>  static void __bm_unmap(unsigned long *p_addr, const enum km_type km)
>  {
> -       kunmap_atomic(p_addr, km);
> +       kunmap_atomic(p_addr);
>  };
>  =20

Stuff like that is really only a half-assed cleanup, IIRC there's more
sites like that.

In my initial massive patch I cleaned all that up as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
