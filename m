Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EDCBD6B0085
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 13:21:20 -0400 (EDT)
Received: by fxm2 with SMTP id 2so186408fxm.6
        for <linux-mm@kvack.org>; Thu, 18 Mar 2010 10:21:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1268903124-10237-7-git-send-email-akinobu.mita@gmail.com>
References: <1268903124-10237-1-git-send-email-akinobu.mita@gmail.com>
	 <1268903124-10237-7-git-send-email-akinobu.mita@gmail.com>
Date: Thu, 18 Mar 2010 19:21:18 +0200
Message-ID: <84144f021003181021t54b0c5baj2947f007c1b48a62@mail.gmail.com>
Subject: Re: [PATCH 07/12] slab: convert cpu notifier to return encapsulate
	errno value
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 18, 2010 at 11:05 AM, Akinobu Mita <akinobu.mita@gmail.com> wro=
te:
> By the previous modification, the cpu notifier can return encapsulate
> errno value. This converts the cpu notifiers for slab.
>
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

> Cc: Matt Mackall <mpm@selenic.com>
> Cc: linux-mm@kvack.org
> ---
> =A0mm/slab.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index a9f325b..d57309e 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1324,7 +1324,7 @@ static int __cpuinit cpuup_callback(struct notifier=
_block *nfb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&cache_chain_mutex);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 return err ? NOTIFY_BAD : NOTIFY_OK;
> + =A0 =A0 =A0 return notifier_from_errno(err);
> =A0}
>
> =A0static struct notifier_block __cpuinitdata cpucache_notifier =3D {
> --
> 1.6.0.6
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
