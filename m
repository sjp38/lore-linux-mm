Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 44C406B004A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 06:34:33 -0400 (EDT)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH 05/16] mm/drivers: use vm_flags_t for vma flags
Date: Wed, 21 Mar 2012 11:34:56 +0100
Message-ID: <3319224.gEMkjEgmG9@avalon>
In-Reply-To: <20120321065633.13852.11903.stgit@zurg>
References: <20120321065140.13852.52315.stgit@zurg> <20120321065633.13852.11903.stgit@zurg>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Mauro Carvalho Chehab <mchehab@infradead.org>, linux-mm@kvack.org, Arve =?ISO-8859-1?Q?Hj=F8nnev=E5g?= <arve@android.com>, John Stultz <john.stultz@linaro.org>, linux-media@vger.kernel.org

Hi Konstantin,

Thanks for the patch.

On Wednesday 21 March 2012 10:56:33 Konstantin Khlebnikov wrote:
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: linux-media@vger.kernel.org
> Cc: devel@driverdev.osuosl.org
> Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
> Cc: Mauro Carvalho Chehab <mchehab@infradead.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: John Stultz <john.stultz@linaro.org>
> Cc: "Arve Hj=F8nnev=E5g" <arve@android.com>
> ---
>  drivers/media/video/omap3isp/ispqueue.h |    2 +-

For the OMAP3 ISP driver,

Acked-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>

>  drivers/staging/android/ashmem.c        |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/media/video/omap3isp/ispqueue.h
> b/drivers/media/video/omap3isp/ispqueue.h index 92c5a12..908dfd7 1006=
44
> --- a/drivers/media/video/omap3isp/ispqueue.h
> +++ b/drivers/media/video/omap3isp/ispqueue.h
> @@ -90,7 +90,7 @@ struct isp_video_buffer {
>  =09void *vaddr;
>=20
>  =09/* For userspace buffers. */
> -=09unsigned long vm_flags;
> +=09vm_flags_t vm_flags;
>  =09unsigned long offset;
>  =09unsigned int npages;
>  =09struct page **pages;
> diff --git a/drivers/staging/android/ashmem.c
> b/drivers/staging/android/ashmem.c index 9f1f27e..4511420 100644
> --- a/drivers/staging/android/ashmem.c
> +++ b/drivers/staging/android/ashmem.c
> @@ -269,7 +269,7 @@ out:
>  =09return ret;
>  }
>=20
> -static inline unsigned long calc_vm_may_flags(unsigned long prot)
> +static inline vm_flags_t calc_vm_may_flags(unsigned long prot)
>  {
>  =09return _calc_vm_trans(prot, PROT_READ,  VM_MAYREAD) |
>  =09       _calc_vm_trans(prot, PROT_WRITE, VM_MAYWRITE) |
>=20

--=20
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
