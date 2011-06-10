Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D5B246B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 12:47:06 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p5AGl28l019028
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:47:04 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by hpaq2.eem.corp.google.com with ESMTP id p5AGj4Nf002064
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:47:00 -0700
Received: by qyk7 with SMTP id 7so1866259qyk.17
        for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:47:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110610164456.cfcdbd0c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110610164456.cfcdbd0c.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 10 Jun 2011 09:47:00 -0700
Message-ID: <BANLkTi=rJVKdhAeAjzfSJ0cMn3GiZpdXusxRL3cPYdJT+Ucneg@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] fix memory.numa_stat file permission
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Fri, Jun 10, 2011 at 12:44 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> I'm sorry I missed this bug because I tested as 'root' ...
>
> =3D
> From 9fe15b548430635d4bbdc2b39e778dbb08e369c9 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 10 Jun 2011 16:50:39 +0900
> Subject: [PATCH][BUGFIX] memcg: fix memory.numa_stat file permission
>
>
> =A0commit 406eb0c9ba765eb066406fd5ce9d5e2b169a4d5a adds memory.numa_stat
> =A0file for memory cgroup. But it's file permission is wrong.
>
> [kamezawa@bluextal linux-2.6]$ ls -l /cgroup/memory/A/memory.numa_stat
> ---------- 1 root root 0 Jun =A09 18:36 /cgroup/memory/A/memory.numa_stat
>
> This patch fixes the permission as
>
> [root@bluextal kamezawa]# ls -l /cgroup/memory/A/memory.numa_stat
> -r--r--r-- 1 root root 0 Jun 10 16:49 /cgroup/memory/A/memory.numa_stat
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0mm/memcontrol.c | =A0 =A01 +
> =A01 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bd9052a..ce05835 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4640,6 +4640,7 @@ static struct cftype mem_cgroup_files[] =3D {
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =3D "numa_stat",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.open =3D mem_control_numa_stat_open,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =3D S_IRUGO,
> =A0 =A0 =A0 =A0},
> =A0#endif
> =A0};
> --
> 1.7.4.1
>
>
>

Acked-by: Ying Han <yinghan@google.com>

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
