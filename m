Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D6CC86B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 02:02:09 -0400 (EDT)
Received: by vxj15 with SMTP id 15so301483vxj.14
        for <linux-mm@kvack.org>; Wed, 03 Aug 2011 23:02:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
Date: Thu, 4 Aug 2011 09:02:05 +0300
Message-ID: <CAOJsxLFofcX3ge26OxbuQ6D-qLvi4L=Xjc1rhzo5E9ddPZBEjQ@mail.gmail.com>
Subject: Re: [PATCH 1/4] page cgroup: using vzalloc instead of vmalloc
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, namhyung@gmail.com, hannes@cmpxchg.org, mhocko@suse.cz, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com

On Thu, Aug 4, 2011 at 6:09 AM, Bob Liu <lliubbo@gmail.com> wrote:
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

> ---
> =A0mm/page_cgroup.c | =A0 =A03 +--
> =A01 files changed, 1 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 39d216d..6bdc67d 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -513,11 +513,10 @@ int swap_cgroup_swapon(int type, unsigned long max_=
pages)
> =A0 =A0 =A0 =A0length =3D DIV_ROUND_UP(max_pages, SC_PER_PAGE);
> =A0 =A0 =A0 =A0array_size =3D length * sizeof(void *);
>
> - =A0 =A0 =A0 array =3D vmalloc(array_size);
> + =A0 =A0 =A0 array =3D vzalloc(array_size);
> =A0 =A0 =A0 =A0if (!array)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto nomem;
>
> - =A0 =A0 =A0 memset(array, 0, array_size);
> =A0 =A0 =A0 =A0ctrl =3D &swap_cgroup_ctrl[type];
> =A0 =A0 =A0 =A0mutex_lock(&swap_cgroup_mutex);
> =A0 =A0 =A0 =A0ctrl->length =3D length;
> --
> 1.6.3.3
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
