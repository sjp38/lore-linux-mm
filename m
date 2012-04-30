Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id B22FB6B004D
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 15:42:29 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2041099qcs.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 12:42:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334959051-18203-11-git-send-email-glommer@parallels.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
	<1334959051-18203-11-git-send-email-glommer@parallels.com>
Date: Mon, 30 Apr 2012 12:42:28 -0700
Message-ID: <CABCjUKDKwJMZioQPBwdiN-SUOW7VQkkBajwbKHUCSz1sdM6dQQ@mail.gmail.com>
Subject: Re: [PATCH 10/23] slab/slub: struct memcg_params
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, Apr 20, 2012 at 2:57 PM, Glauber Costa <glommer@parallels.com> wrot=
e:
> For the kmem slab controller, we need to record some extra
> information in the kmem_cache structure.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Suleiman Souhlal <suleiman@google.com>
> ---
> =A0include/linux/slab.h =A0 =A0 | =A0 15 +++++++++++++++
> =A0include/linux/slab_def.h | =A0 =A04 ++++
> =A0include/linux/slub_def.h | =A0 =A03 +++
> =A03 files changed, 22 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index a595dce..a5127e1 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -153,6 +153,21 @@ unsigned int kmem_cache_size(struct kmem_cache *);
> =A0#define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
> =A0#endif
>
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +struct mem_cgroup_cache_params {
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> + =A0 =A0 =A0 int id;
> +
> +#ifdef CONFIG_SLAB
> + =A0 =A0 =A0 /* Original cache parameters, used when creating a memcg ca=
che */
> + =A0 =A0 =A0 size_t orig_align;
> + =A0 =A0 =A0 atomic_t refcnt;
> +
> +#endif
> + =A0 =A0 =A0 struct list_head destroyed_list; /* Used when deleting cpus=
et cache */

s,cpuset,memcg,

Sorry about that.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
