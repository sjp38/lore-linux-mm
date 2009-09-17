Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 541D86B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 01:55:13 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so1717077qwf.44
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 22:55:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090917114256.1f3971d8.kamezawa.hiroyu@jp.fujitsu.com>
References: <2375c9f90909160235m1f052df0qb001f8243ed9291e@mail.gmail.com>
	 <1bc66b163326564dafb5a7dd8959fd56.squirrel@webmail-b.css.fujitsu.com>
	 <20090917114138.e14a1183.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090917114256.1f3971d8.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 17 Sep 2009 13:55:20 +0800
Message-ID: <2375c9f90909162255i3dca34e8w51e496294bb38916@mail.gmail.com>
Subject: Re: [PATCH 1/3][mmotm] kcore: more fixes for init
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 17, 2009 at 10:42 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> proc_kcore_init() doesn't check NULL case.
> fix it and remove unnecessary comments.
>
> Cc: WANG Cong <xiyou.wangcong@gmail.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: WANG Cong <xiyou.wangcong@gmail.com>

Thanks.

> ---
> =C2=A0fs/proc/kcore.c | =C2=A0 =C2=A05 ++++-
> =C2=A01 file changed, 4 insertions(+), 1 deletion(-)
>
> Index: mmotm-2.6.31-Sep14/fs/proc/kcore.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.31-Sep14.orig/fs/proc/kcore.c
> +++ mmotm-2.6.31-Sep14/fs/proc/kcore.c
> @@ -606,6 +606,10 @@ static int __init proc_kcore_init(void)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0proc_root_kcore =3D proc_create("kcore", S_IRU=
SR, NULL,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&proc_kcore_oper=
ations);
> + =C2=A0 =C2=A0 =C2=A0 if (!proc_root_kcore) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_ERR "could=
n't create /proc/kcore\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0; /* Always re=
turns 0. */
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Store text area if it's special */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0proc_kcore_text_init();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Store vmalloc area */
> @@ -615,7 +619,6 @@ static int __init proc_kcore_init(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Store direct-map area from physical memory =
map */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0kcore_update_ram();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0hotplug_memory_notifier(kcore_callback, 0);
> - =C2=A0 =C2=A0 =C2=A0 /* Other special area, area-for-module etc is arch=
 specific. */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
