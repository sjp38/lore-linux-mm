Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 438346B0005
	for <linux-mm@kvack.org>; Mon, 11 Mar 2013 01:21:17 -0400 (EDT)
Message-ID: <513D689C.5030105@cn.fujitsu.com>
Date: Mon, 11 Mar 2013 13:16:12 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2, part1 29/29] mm,kexec: use common help functions to
 free reserved pages
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com> <1362896833-21104-30-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-30-git-send-email-jiang.liu@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>

=D3=DA 2013=C4=EA03=D4=C210=C8=D5 14:27, Jiang Liu =D0=B4=B5=C0:
> Use common help functions to free reserved pages.
>=20
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: Eric Biederman <ebiederm@xmission.com>

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> ---
>  kernel/kexec.c |    8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
>=20
> diff --git a/kernel/kexec.c b/kernel/kexec.c
> index bddd3d7..be95397 100644
> --- a/kernel/kexec.c
> +++ b/kernel/kexec.c
> @@ -1118,12 +1118,8 @@ void =5F=5Fweak crash=5Ffree=5Freserved=5Fphys=5Fr=
ange(unsigned long begin,
>  {
>  	unsigned long addr;
> =20
> -	for (addr =3D begin; addr < end; addr +=3D PAGE=5FSIZE) {
> -		ClearPageReserved(pfn=5Fto=5Fpage(addr >> PAGE=5FSHIFT));
> -		init=5Fpage=5Fcount(pfn=5Fto=5Fpage(addr >> PAGE=5FSHIFT));
> -		free=5Fpage((unsigned long)=5F=5Fva(addr));
> -		totalram=5Fpages++;
> -	}
> +	for (addr =3D begin; addr < end; addr +=3D PAGE=5FSIZE)
> +		free=5Freserved=5Fpage(pfn=5Fto=5Fpage(addr >> PAGE=5FSHIFT));
>  }
> =20
>  int crash=5Fshrink=5Fmemory(unsigned long new=5Fsize)

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
