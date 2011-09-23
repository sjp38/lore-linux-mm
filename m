Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DC1CE9000BD
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 01:52:12 -0400 (EDT)
Received: by fxh17 with SMTP id 17so4545959fxh.14
        for <linux-mm@kvack.org>; Thu, 22 Sep 2011 22:52:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201109221815.08891.hartleys@visionengravers.com>
References: <201109221815.08891.hartleys@visionengravers.com>
Date: Fri, 23 Sep 2011 11:22:08 +0530
Message-ID: <CAKTCnznRZbcsnHyV=+-DDd2fkAZ+kqyqrCoos+4ZmBxGBPNQYg@mail.gmail.com>
Subject: Re: [PATCH] mm/page_cgroup.c: quiet sparse noise
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, containers@lists.linux-foundation.org, paul@paulmenage.org, lizf@cn.fujitsu.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com

On Fri, Sep 23, 2011 at 6:45 AM, H Hartley Sweeten
<hartleys@visionengravers.com> wrote:
> Quite the sparse noise:
>
> warning: symbol 'swap_cgroup_ctrl' was not declared. Should it be static?
>
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Cc: Paul Menage <paul@paulmenage.org>
> Cc: Li Zefan <lizf@cn.fujitsu.com>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> ---
>
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 6bdc67d..eead840 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -357,7 +357,7 @@ struct swap_cgroup_ctrl {
> =A0 =A0 =A0 =A0spinlock_t =A0 =A0 =A0lock;
> =A0};
>
> -struct swap_cgroup_ctrl swap_cgroup_ctrl[MAX_SWAPFILES];
> +static struct swap_cgroup_ctrl swap_cgroup_ctrl[MAX_SWAPFILES];

Seems reasonable

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
