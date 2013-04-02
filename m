Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 8834E6B0006
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 10:18:57 -0400 (EDT)
Date: Tue, 2 Apr 2013 10:18:50 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 2/2] drivers: staging: zcache: fix compile warning
Message-ID: <20130402141850.GE1754@phenom.dumpdata.com>
References: <1364870864-13888-1-git-send-email-bob.liu@oracle.com>
 <1364870864-13888-2-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1364870864-13888-2-git-send-email-bob.liu@oracle.com>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: gregkh@linuxfoundation.org, dan.magenheimer@oracle.com, fengguang.wu@intel.com, linux-mm@kvack.org, akpm@linux-foundation.org, Bob Liu <bob.liu@oracle.com>

On Tue, Apr 02, 2013 at 10:47:43AM +0800, Bob Liu wrote:
> Fix below compile warning:
> staging/zcache/zcache-main.c: In function =E2=80=98zcache_autocreate_po=
ol=E2=80=99:
> staging/zcache/zcache-main.c:1393:13: warning: =E2=80=98cli=E2=80=99 ma=
y be used uninitialized
> in this function [-Wuninitialized]
>=20
> Signed-off-by: Bob Liu <bob.liu@oracle.com>

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  drivers/staging/zcache/zcache-main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zca=
che/zcache-main.c
> index ac75670..7999021 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -1341,7 +1341,7 @@ static int zcache_local_new_pool(uint32_t flags)
>  int zcache_autocreate_pool(unsigned int cli_id, unsigned int pool_id, =
bool eph)
>  {
>  	struct tmem_pool *pool;
> -	struct zcache_client *cli;
> +	struct zcache_client *cli =3D NULL;
>  	uint32_t flags =3D eph ? 0 : TMEM_POOL_PERSIST;
>  	int ret =3D -1;
> =20
> --=20
> 1.7.10.4
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
