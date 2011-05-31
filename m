Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9227F6B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 15:47:53 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p4VJln3p001478
	for <linux-mm@kvack.org>; Tue, 31 May 2011 12:47:49 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by wpaz1.hot.corp.google.com with ESMTP id p4VJllSh008926
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 31 May 2011 12:47:48 -0700
Received: by pzk36 with SMTP id 36so2938652pzk.34
        for <linux-mm@kvack.org>; Tue, 31 May 2011 12:47:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <f3d616b526e00bd8f01a250b7ce8c5a6e2412768.1306603968.git.joe@perches.com>
References: <cover.1306603968.git.joe@perches.com> <f3d616b526e00bd8f01a250b7ce8c5a6e2412768.1306603968.git.joe@perches.com>
From: Paul Menage <menage@google.com>
Date: Tue, 31 May 2011 12:47:27 -0700
Message-ID: <BANLkTikFwfQrvEwHcx5iJe+m8HaGyQ_9BN-0n8C0X5cPjNnOPw@mail.gmail.com>
Subject: Re: [TRIVIAL PATCH next 14/15] mm: Convert vmalloc/memset to vzalloc
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Jiri Kosina <trivial@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Containers <containers@lists.linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, May 28, 2011 at 10:36 AM, Joe Perches <joe@perches.com> wrote:
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Paul Menage <menage@google.com>

> ---
> =A0mm/page_cgroup.c | =A0 =A03 +--
> =A01 files changed, 1 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 74ccff6..dbb28fd 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -478,11 +478,10 @@ int swap_cgroup_swapon(int type, unsigned long max_=
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
> 1.7.5.rc3.dirty
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
