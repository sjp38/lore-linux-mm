Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 10FF26B0038
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 09:15:57 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so31513163wid.3
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 06:15:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id wc6si40296201wjc.1.2014.12.03.06.15.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Dec 2014 06:15:56 -0800 (PST)
Message-ID: <547F1B00.3030706@redhat.com>
Date: Wed, 03 Dec 2014 15:15:28 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] zram: use DEVICE_ATTR_[RW|RO|WO] to define zram sys device
 attribute
References: <1417610332-11191-1-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1417610332-11191-1-git-send-email-opensource.ganesh@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="LwdosRSQnhntDJPpDbQaNKE5atdEuewOq"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>, minchan@kernel.org, ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--LwdosRSQnhntDJPpDbQaNKE5atdEuewOq
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/03/2014 01:38 PM, Ganesh Mahendran wrote:
> In current zram, we use DEVICE_ATTR() to define sys device attributes.
> SO, we need to set (S_IRUGO | S_IWUSR) permission and other
> arguments manually.
> Linux kernel has already provided macro DEVICE_ATTR_[RW|RO|WO] to defin=
e
> sys device attribute. It is simple and readable.

It does look cleaner.

>=20
> This patch uses kernel defined macro DEVICE_ATTR_[RW|RO|WO] to define
> zram device attribute.
>=20
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

Thanks,
Jerome
> ---
>  drivers/block/zram/zram_drv.c |   28 +++++++++++-----------------
>  1 file changed, 11 insertions(+), 17 deletions(-)
>=20
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_dr=
v.c
> index 8eb0d85..53fbd61 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -44,15 +44,14 @@ static const char *default_compressor =3D "lzo";
>  static unsigned int num_devices =3D 1;
> =20
>  #define ZRAM_ATTR_RO(name)						\
> -static ssize_t zram_attr_##name##_show(struct device *d,		\
> +static ssize_t name##_show(struct device *d,		\
>  				struct device_attribute *attr, char *b)	\
>  {									\
>  	struct zram *zram =3D dev_to_zram(d);				\
>  	return scnprintf(b, PAGE_SIZE, "%llu\n",			\
>  		(u64)atomic64_read(&zram->stats.name));			\
>  }									\
> -static struct device_attribute dev_attr_##name =3D			\
> -	__ATTR(name, S_IRUGO, zram_attr_##name##_show, NULL);
> +static DEVICE_ATTR_RO(name);
> =20
>  static inline int init_done(struct zram *zram)
>  {
> @@ -994,20 +993,15 @@ static const struct block_device_operations zram_=
devops =3D {
>  	.owner =3D THIS_MODULE
>  };
> =20
> -static DEVICE_ATTR(disksize, S_IRUGO | S_IWUSR,
> -		disksize_show, disksize_store);
> -static DEVICE_ATTR(initstate, S_IRUGO, initstate_show, NULL);
> -static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
> -static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL)=
;
> -static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL)=
;
> -static DEVICE_ATTR(mem_limit, S_IRUGO | S_IWUSR, mem_limit_show,
> -		mem_limit_store);
> -static DEVICE_ATTR(mem_used_max, S_IRUGO | S_IWUSR, mem_used_max_show,=

> -		mem_used_max_store);
> -static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
> -		max_comp_streams_show, max_comp_streams_store);
> -static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
> -		comp_algorithm_show, comp_algorithm_store);
> +static DEVICE_ATTR_RW(disksize);
> +static DEVICE_ATTR_RO(initstate);
> +static DEVICE_ATTR_WO(reset);
> +static DEVICE_ATTR_RO(orig_data_size);
> +static DEVICE_ATTR_RO(mem_used_total);
> +static DEVICE_ATTR_RW(mem_limit);
> +static DEVICE_ATTR_RW(mem_used_max);
> +static DEVICE_ATTR_RW(max_comp_streams);
> +static DEVICE_ATTR_RW(comp_algorithm);
> =20
>  ZRAM_ATTR_RO(num_reads);
>  ZRAM_ATTR_RO(num_writes);
>=20



--LwdosRSQnhntDJPpDbQaNKE5atdEuewOq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUfxsAAAoJEHTzHJCtsuoCWqkH/00PDe6xm9TLSd8HqvgRswP1
pHrBnZYoFV+wbSoXq1zfDcDrWTihoDtWy3nqsqy/kCkD30oEipqh+J3HXmhxwIzT
T83wdYtgIXmOrbFDdS56OkbHIdTKrRYh+6Tp+2k8P2ym6HkDJ5tMzS01qr13iyOy
tokeWIc5O0wndsQQG9rlLhMO+QPQzGd1ufTKzSQ0BeeLigFVPqrh4FvUYkAsCM8L
0k3xyzSduAeQu1IiEJbvGGeG25u4YmXB2S+iTAOYDui4H1ocXeafPp4JslEhJlpR
9GXpgEhGLGpwfT9GrfftpZbdeNxVSzOtHprnpe2ZJUDy3+D0Z8t90mKs/EvZhM0=
=x1NZ
-----END PGP SIGNATURE-----

--LwdosRSQnhntDJPpDbQaNKE5atdEuewOq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
