Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F26B96B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 20:09:27 -0500 (EST)
Received: by pxi2 with SMTP id 2so119200pxi.11
        for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:09:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091210170036.dde2c147.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091210170036.dde2c147.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 11 Dec 2009 10:09:25 +0900
Message-ID: <28c262360912101709o54ebd549v31b5bcde0fc8613@mail.gmail.com>
Subject: Re: [RFC mm][PATCH 4/5] add a lowmem check function
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Thu, Dec 10, 2009 at 5:00 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Final purpose of this patch is for improving oom/memoy shortage detection
> better. In general there are OOM cases that lowmem is exhausted. What
> this lowmem means is determined by the situation, but in general,
> limited amount of memory for some special use is lowmem.
>
> This patch adds an integer lowmem_zone, which is initialized to -1.
> If zone_idx(zone) <=3D lowmem_zone, the zone is lowmem.
>
> This patch uses simple definition that the zone for special use is the lo=
wmem.
> Not taking the amount of memory into account.
>
> For example,
> =C2=A0- if HIGHMEM is used, NORMAL is lowmem.
> =C2=A0- If the system has both of NORMAL and DMA32, DMA32 is lowmem.
> =C2=A0- When the system consists of only one zone, there are no lowmem.
>
> This will be used for lowmem accounting per mm_struct and its information
> will be used for oom-killer.
>
> Changelog: 2009/12/09
> =C2=A0- stop using policy_zone and use unified definition on each config.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I like this than policy_zone version.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
