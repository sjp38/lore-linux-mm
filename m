Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DABBC6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:27:44 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 28so401869wfa.11
        for <linux-mm@kvack.org>; Fri, 13 Mar 2009 07:27:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090313230627.3fa31cef.d-nishimura@mtf.biglobe.ne.jp>
References: <20090313230627.3fa31cef.d-nishimura@mtf.biglobe.ne.jp>
Date: Fri, 13 Mar 2009 23:27:43 +0900
Message-ID: <2f11576a0903130727l7812da61i2e352eea455378e8@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] vmscan: pgmoved should be cleared after updating
	recent_rotated
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

> @@ -1262,7 +1262,6 @@ static void shrink_active_list(unsigned long nr_pag=
es, struct zone *zone,
> =A0 =A0 =A0 =A0 * Move the pages to the [file or anon] inactive list.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0pagevec_init(&pvec, 1);
> - =A0 =A0 =A0 pgmoved =3D 0;
> =A0 =A0 =A0 =A0lru =3D LRU_BASE + file * LRU_FILE;
>
> =A0 =A0 =A0 =A0spin_lock_irq(&zone->lru_lock);
> @@ -1274,6 +1273,7 @@ static void shrink_active_list(unsigned long nr_pag=
es, struct zone *zone,
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0reclaim_stat->recent_rotated[!!file] +=3D pgmoved;
>
> + =A0 =A0 =A0 pgmoved =3D 0;

Thanks!
    Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


Andrew, this problem introduced by
b555749aac87d7c2637f153e44bd77c7fdf4c65b (Jan 6).
IOW, it was introduced 2.6.29-rc1. then, I hope this patch merge to
2.6.29 series.

Is this possible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
