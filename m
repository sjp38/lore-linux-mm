Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 729696B0069
	for <linux-mm@kvack.org>; Sat, 18 Oct 2014 00:50:11 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id m20so1599410qcx.15
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 21:50:11 -0700 (PDT)
Received: from nm16.bullet.mail.bf1.yahoo.com (nm16.bullet.mail.bf1.yahoo.com. [98.139.212.175])
        by mx.google.com with ESMTPS id u8si5564252qcj.26.2014.10.17.21.50.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Oct 2014 21:50:09 -0700 (PDT)
References: <1471435.6q4YYkTopF@vostro.rjw.lan> <1413538084-15743-1-git-send-email-zhuhui@xiaomi.com>
Message-ID: <1413607808.82877.YahooMailNeo@web160105.mail.bf1.yahoo.com>
Date: Fri, 17 Oct 2014 21:50:08 -0700
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: [PATCH v2 2/4] (CMA_AGGRESSIVE) Add new function shrink_all_memory_for_cma
In-Reply-To: <1413538084-15743-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>, "len.brown@intel.com" <len.brown@intel.com>, "pavel@ucw.cz" <pavel@ucw.cz>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mina86@mina86.com" <mina86@mina86.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, "mgorman@suse.de" <mgorman@suse.de>, "minchan@kernel.org" <minchan@kernel.org>, "nasa4836@gmail.com" <nasa4836@gmail.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "hughd@google.com" <hughd@google.com>, "mingo@kernel.org" <mingo@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "peterz@infradead.org" <peterz@infradead.org>, "keescook@chromium.org" <keescook@chromium.org>, "atomlin@redhat.com" <atomlin@redhat.com>, "raistlin@linux.it" <raistlin@linux.it>, "axboe@fb.com" <axboe@fb.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "k.khlebnikov@samsung.com" <k.khlebnikov@samsung.com>, "msalter@redhat.com" <msalter@redhat.com>, "deller@gmx.de" <deller@gmx.de>, "tangchen@cn.fujitsu.com" <tangchen@cn.fujitsu.com>, "ben@decadent.org.uk" <ben@decadent.org.uk>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "lauraa@codeaurora.org" <lauraa@codeaurora.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "suleiman@google.com" <suleiman@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pintu_agarwal@yahoo.com" <pintu_agarwal@yahoo.com>, "pintu.k@samsung.com" <pintu.k@samsung.com>

Hi,=0A=0A=0A=0A----- Original Message -----=0A> From: Hui Zhu <zhuhui@xiaom=
i.com>=0A> To: rjw@rjwysocki.net; len.brown@intel.com; pavel@ucw.cz; m.szyp=
rowski@samsung.com; akpm@linux-foundation.org; mina86@mina86.com; aneesh.ku=
mar@linux.vnet.ibm.com; iamjoonsoo.kim@lge.com; hannes@cmpxchg.org; riel@re=
dhat.com; mgorman@suse.de; minchan@kernel.org; nasa4836@gmail.com; ddstreet=
@ieee.org; hughd@google.com; mingo@kernel.org; rientjes@google.com; peterz@=
infradead.org; keescook@chromium.org; atomlin@redhat.com; raistlin@linux.it=
; axboe@fb.com; paulmck@linux.vnet.ibm.com; kirill.shutemov@linux.intel.com=
; n-horiguchi@ah.jp.nec.com; k.khlebnikov@samsung.com; msalter@redhat.com; =
deller@gmx.de; tangchen@cn.fujitsu.com; ben@decadent.org.uk; akinobu.mita@g=
mail.com; lauraa@codeaurora.org; vbabka@suse.cz; sasha.levin@oracle.com; vd=
avydov@parallels.com; suleiman@google.com=0A> Cc: linux-kernel@vger.kernel.=
org; linux-pm@vger.kernel.org; linux-mm@kvack.org; Hui Zhu <zhuhui@xiaomi.c=
om>=0A> Sent: Friday, 17 October 2014 2:58 PM=0A> Subject: [PATCH v2 2/4] (=
CMA_AGGRESSIVE) Add new function shrink_all_memory_for_cma=0A> =0A> Update =
this patch according to the comments from Rafael.=0A> =0A> Function shrink_=
all_memory_for_cma try to free `nr_to_reclaim' of memory.=0A> CMA aggressiv=
e shrink function will call this functon to free =0A> `nr_to_reclaim' of=0A=
> memory.=0A=0AInstead, we can have in short shrink_cma_memory(nr_to_reclai=
m).=0ASometime back I already proposed to have shrink_memory for CMA here:=
=0Ahttp://lists.infradead.org/pipermail/linux-arm-kernel/2013-January/14310=
3.html=0A=0ANow, I am working on another solution that uses shrink_all_memo=
ry().=0AThis can be helpful even for non CMA cases as well to bring back th=
e higher-order pages quickly.=0AWill post the patches until next week.=0A=
=0A=0A> =0A> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>=0A> ---=0A> mm/vmsc=
an.c | 58 +++++++++++++++++++++++++++++++++++++++++++---------------=0A> 1 =
file changed, 43 insertions(+), 15 deletions(-)=0A> =0A> diff --git a/mm/vm=
scan.c b/mm/vmscan.c=0A> index dcb4707..658dc8d 100644=0A> --- a/mm/vmscan.=
c=0A> +++ b/mm/vmscan.c=0A> @@ -3404,6 +3404,28 @@ void wakeup_kswapd(struc=
t zone *zone, int order, enum =0A> zone_type classzone_idx)=0A>     wake_up=
_interruptible(&pgdat->kswapd_wait);=0A> }=0A> =0A> +#if defined CONFIG_HIB=
ERNATION || defined CONFIG_CMA_AGGRESSIVE=0A> +static unsigned long __shrin=
k_all_memory(struct scan_control *sc)=0A> +{=0A> +    struct reclaim_state =
reclaim_state;=0A> +    struct zonelist *zonelist =3D node_zonelist(numa_no=
de_id(), sc->gfp_mask);=0A> +    struct task_struct *p =3D current;=0A> +  =
  unsigned long nr_reclaimed;=0A> +=0A> +    p->flags |=3D PF_MEMALLOC;=0A>=
 +    lockdep_set_current_reclaim_state(sc->gfp_mask);=0A> +    reclaim_sta=
te.reclaimed_slab =3D 0;=0A> +    p->reclaim_state =3D &reclaim_state;=0A> =
+=0A> +    nr_reclaimed =3D do_try_to_free_pages(zonelist, sc);=0A> +=0A> +=
    p->reclaim_state =3D NULL;=0A> +    lockdep_clear_current_reclaim_state=
();=0A> +    p->flags &=3D ~PF_MEMALLOC;=0A> +=0A> +    return nr_reclaimed=
;=0A> +}=0A> +=0A> #ifdef CONFIG_HIBERNATION=0A> /*=0A>   * Try to free `nr=
_to_reclaim' of memory, system-wide, and return the =0A> number of=0A> @@ -=
3415,7 +3437,6 @@ void wakeup_kswapd(struct zone *zone, int order, enum =0A=
> zone_type classzone_idx)=0A>   */=0A> unsigned long shrink_all_memory(uns=
igned long nr_to_reclaim)=0A> {=0A> -    struct reclaim_state reclaim_state=
;=0A>     struct scan_control sc =3D {=0A>         .nr_to_reclaim =3D nr_to=
_reclaim,=0A>         .gfp_mask =3D GFP_HIGHUSER_MOVABLE,=0A> @@ -3425,24 +=
3446,31 @@ unsigned long shrink_all_memory(unsigned long =0A> nr_to_reclaim=
)=0A>         .may_swap =3D 1,=0A>         .hibernation_mode =3D 1,=0A>    =
 };=0A> -    struct zonelist *zonelist =3D node_zonelist(numa_node_id(), sc=
.gfp_mask);=0A> -    struct task_struct *p =3D current;=0A> -    unsigned l=
ong nr_reclaimed;=0A> -=0A> -    p->flags |=3D PF_MEMALLOC;=0A> -    lockde=
p_set_current_reclaim_state(sc.gfp_mask);=0A> -    reclaim_state.reclaimed_=
slab =3D 0;=0A> -    p->reclaim_state =3D &reclaim_state;=0A> =0A> -    nr_=
reclaimed =3D do_try_to_free_pages(zonelist, &sc);=0A> +    return __shrink=
_all_memory(&sc);=0A> +}=0A> +#endif /* CONFIG_HIBERNATION */=0A> =0A> -   =
 p->reclaim_state =3D NULL;=0A> -    lockdep_clear_current_reclaim_state();=
=0A> -    p->flags &=3D ~PF_MEMALLOC;=0A> +#ifdef CONFIG_CMA_AGGRESSIVE=0A>=
 +/*=0A> + * Try to free `nr_to_reclaim' of memory, system-wide, for CMA ag=
gressive=0A> + * shrink function.=0A> + */=0A> +void shrink_all_memory_for_=
cma(unsigned long nr_to_reclaim)=0A> +{=0A> +    struct scan_control sc =3D=
 {=0A> +        .nr_to_reclaim =3D nr_to_reclaim,=0A> +        .gfp_mask =
=3D GFP_USER | __GFP_MOVABLE | __GFP_HIGHMEM,=0A> +        .priority =3D DE=
F_PRIORITY,=0A> +        .may_writepage =3D !laptop_mode,=0A> +        .may=
_unmap =3D 1,=0A> +        .may_swap =3D 1,=0A> +    };=0A> =0A> -    retur=
n nr_reclaimed;=0A> +    __shrink_all_memory(&sc);=0A> }=0A> -#endif /* CON=
FIG_HIBERNATION */=0A> +#endif /* CONFIG_CMA_AGGRESSIVE */=0A> +#endif /* C=
ONFIG_HIBERNATION || CONFIG_CMA_AGGRESSIVE */=0A> =0A> /* It's optimal to k=
eep kswapds on the same CPUs as their memory, but=0A>     not required for =
correctness.  So if the last cpu in a node goes=0A> -- =0A> 1.9.1=0A> =0A> =
=0A> --=0A> To unsubscribe, send a message with 'unsubscribe linux-mm' in=
=0A> the body to majordomo@kvack.org.  For more info on Linux MM,=0A> see: =
http://www.linux-mm.org/ .=0A> Don't email: <a href=3Dmailto:"dont@kvack.or=
g"> =0A> email@kvack.org </a>=0A> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
