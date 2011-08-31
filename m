Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C902A6B00EE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 11:14:42 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <a5b32916-8539-43fe-a63c-0564ebd4e76f@default>
Date: Wed, 31 Aug 2011 08:14:19 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: mm: frontswap: core code
References: <20110830214703.GB3705@shale.localdomain>
In-Reply-To: <20110830214703.GB3705@shale.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <error27@gmail.com>
Cc: linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>

> From: Dan Carpenter [mailto:error27@gmail.com]
> Sent: Tuesday, August 30, 2011 3:47 PM
> To: Dan Magenheimer
> Cc: linux-mm@kvack.org
> Subject: re: mm: frontswap: core code
>=20
> Hello Dan Magenheimer,
>=20
> This is a semi-automatic email to let you know that df0aade19b6a:
> "mm: frontswap: core code" leads to the following Smatch complaint.
>=20
> mm/frontswap.c +250 frontswap_curr_pages(7)
> =09 error: we previously assumed 'si' could be null (see line 252)
>=20
> mm/frontswap.c
>    249=09=09spin_lock(&swap_lock);
>    250=09=09for (type =3D swap_list.head; type >=3D 0; type =3D si->next)=
 {
>                                                               ^^^^^^^^
> Dereference.
>=20
>    251=09=09=09si =3D swap_info[type];
>    252=09=09=09if (si !=3D NULL)
>                             ^^^^^^^^^^
> Check for NULL.
>=20
>    253=09=09=09=09totalpages +=3D atomic_read(&si->frontswap_pages);
>    254=09=09}
>=20
> These semi-automatic emails are in testing.  Let me know how they can
> be improved.
>=20
> regards,
> dan carpenter

Thanks Dan!  On second look, the check for si against NULL is
unnecessary.  The "type >=3D0" guarantees that (and this idiom
for walking the list of swap devices is used elsewhere in the
swap subsystem).

Will fix it.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
