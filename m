Received: by wa-out-1112.google.com with SMTP id j37so1079694waf.22
        for <linux-mm@kvack.org>; Sun, 30 Nov 2008 06:00:06 -0800 (PST)
Message-ID: <2f11576a0811300600r6e23b12frf45c165eab2e398b@mail.gmail.com>
Date: Sun, 30 Nov 2008 23:00:05 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 02/09] memcg: make inactive_anon_is_low()
In-Reply-To: <20081130122554.GA12552@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20081130195508.814B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20081130122554.GA12552@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> | +static void mem_cgroup_set_inactive_ratio(struct mem_cgroup *memcg)
> | +{
> | +     unsigned int gb, ratio;
> | +
> | +     gb = res_counter_read_u64(&memcg->res, RES_LIMIT) >> 30;
> | +     ratio = int_sqrt(10 * gb);
> | +     if (!ratio)
> | +             ratio = 1;
>
> Hi Kosaki,
>
> maybe better would be
>
>        gb = ...;
>        if (gb) {
>                ratio = int_sqrt(10 * gb);
>        } else
>                ratio = 1;
>

Will fix.
Thanks.

Actually, setup_per_zone_inactive_ratio() (it calcule for global
reclaim) also have the same non-easy review thning.

I also fix it later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
