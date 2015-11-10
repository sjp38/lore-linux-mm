Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 88A546B0253
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 17:38:29 -0500 (EST)
Received: by qkas77 with SMTP id s77so5512564qka.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 14:38:29 -0800 (PST)
Received: from BLU004-OMC1S19.hotmail.com (blu004-omc1s19.hotmail.com. [65.55.116.30])
        by mx.google.com with ESMTPS id 82si4940093qhs.124.2015.11.10.14.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 10 Nov 2015 14:38:28 -0800 (PST)
Message-ID: <BLU437-SMTP40A19012B65D8572EF89C0B9140@phx.gbl>
Date: Wed, 11 Nov 2015 06:40:58 +0800
From: Chen Gang <xili_gchen_5257@hotmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mmap.c: Remove redundant local variables for may_expand_vm()
References: <COL130-W65418E50E899195C9B2134B9150@phx.gbl>
In-Reply-To: <COL130-W65418E50E899195C9B2134B9150@phx.gbl>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "oleg@redhat.com" <oleg@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "dave@stgolabs.net" <dave@stgolabs.net>, "aarcange@redhat.com" <aarcange@redhat.com>
Cc: Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>


Next=2C I shall read through another files.

I should not only send trivial patches to community=2C I should continue
learning mm.=20

Until now=2C I did not spend enough time resources on mm. So next=2C I
should spend a little more my free time resources on mm.


Welcome any ideas=2C suggestions=2C and completions from any members.

Thanks.

On 11/10/15 05:41=2C Chen Gang wrote:
> From 7050c267d8dda220226067039d815593d2f9a874 Mon Sep 17 00:00:00 2001
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> Date: Tue=2C 10 Nov 2015 05:32:38 +0800
> Subject: [PATCH] mm/mmap.c: Remove redundant local variables for may_expa=
nd_vm()
>=20
> After merge the related code into one line=2C the code is still simple an=
d
> meaningful enough.
>=20
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  mm/mmap.c | 7 +------
>  1 file changed=2C 1 insertion(+)=2C 6 deletions(-)
>=20
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 2ce04a6..a515260 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2988=2C12 +2988=2C7 @@ out:
>   */
>  int may_expand_vm(struct mm_struct *mm=2C unsigned long npages)
>  {
> -	unsigned long cur =3D mm->total_vm=3B	/* pages */
> -	unsigned long lim=3B
> -
> -	lim =3D rlimit(RLIMIT_AS)>> PAGE_SHIFT=3B
> -
> -	if (cur + npages> lim)
> +	if (mm->total_vm + npages> (rlimit(RLIMIT_AS)>> PAGE_SHIFT))
>  		return 0=3B
>  	return 1=3B
>  }
> --=20
> 1.9.3
>=20
>  		 	   		 =20
>=20

--=20
Chen Gang (=E9=99=88=E5=88=9A)

Open=2C share=2C and attitude like air=2C water=2C and life which God bless=
ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
