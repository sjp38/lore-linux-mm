Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 517786B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 09:58:49 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so97329638pdb.2
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 06:58:49 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id ot9si2957992pbb.203.2015.03.27.06.58.48
        for <linux-mm@kvack.org>;
        Fri, 27 Mar 2015 06:58:48 -0700 (PDT)
Date: Fri, 27 Mar 2015 09:58:47 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [patch 1/2] mm, doc: cleanup and clarify munmap behavior for
 hugetlb memory
Message-ID: <20150327135847.GB10747@akamai.com>
References: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KFztAG8eRSV9hGtP"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Davide Libenzi <davidel@xmailserver.org>, Luiz Capitulino <lcapitulino@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-doc@vger.kernel.org


--KFztAG8eRSV9hGtP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 26 Mar 2015, David Rientjes wrote:

> munmap(2) of hugetlb memory requires a length that is hugepage aligned,
> otherwise it may fail.  Add this to the documentation.
>=20
> This also cleans up the documentation and separates it into logical
> units: one part refers to MAP_HUGETLB and another part refers to
> requirements for shared memory segments.
>=20
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---

If this is the route we are going to take, this behavoir needs to be
called out prominently in the mmap/munmap man page.


>  Documentation/vm/hugetlbpage.txt | 21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
>=20
> diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbp=
age.txt
> --- a/Documentation/vm/hugetlbpage.txt
> +++ b/Documentation/vm/hugetlbpage.txt
> @@ -289,15 +289,20 @@ file systems, write system calls are not.
>  Regular chown, chgrp, and chmod commands (with right permissions) could =
be
>  used to change the file attributes on hugetlbfs.
> =20
> -Also, it is important to note that no such mount command is required if =
the
> +Also, it is important to note that no such mount command is required if
>  applications are going to use only shmat/shmget system calls or mmap with
> -MAP_HUGETLB.  Users who wish to use hugetlb page via shared memory segme=
nt
> -should be a member of a supplementary group and system admin needs to
> -configure that gid into /proc/sys/vm/hugetlb_shm_group.  It is possible =
for
> -same or different applications to use any combination of mmaps and shm*
> -calls, though the mount of filesystem will be required for using mmap ca=
lls
> -without MAP_HUGETLB.  For an example of how to use mmap with MAP_HUGETLB=
 see
> -map_hugetlb.c.
> +MAP_HUGETLB.  For an example of how to use mmap with MAP_HUGETLB see map=
_hugetlb
> +below.
> +
> +Users who wish to use hugetlb memory via shared memory segment should be=
 a
> +member of a supplementary group and system admin needs to configure that=
 gid
> +into /proc/sys/vm/hugetlb_shm_group.  It is possible for same or differe=
nt
> +applications to use any combination of mmaps and shm* calls, though the =
mount of
> +filesystem will be required for using mmap calls without MAP_HUGETLB.
> +
> +When using munmap(2) to unmap hugetlb memory, the length specified must =
be
> +hugepage aligned, otherwise it will fail with errno set to EINVAL.
> +
> =20
>  Examples
>  =3D=3D=3D=3D=3D=3D=3D=3D
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--KFztAG8eRSV9hGtP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVFWIXAAoJELbVsDOpoOa9JnAP/j6Rz7l6Od6nv+u/4fBho3Nq
CKvxicBLgsD8ZLJ7Sp9TuJE9aLGMntRY+JylQFAW+YzVbHGW6rlFHepqPyNY2RqT
ITgGv04U0stJYY0RAX6JX5diCzmaIWTaBwBzMAn43wTQSGkGrubo2KrPPNUq8Tof
2oDjIyGO5RuE3/JafG8uhPBwxHDAq8w4d6YjoKkF/aaYSArKq5Jv0QnPEj3osGZu
QKrjyMqHMbBhQzvd9ft27oqThddu9Fyra6WSzp+fTJhav/3KnyLMdj+r9SkRbFjk
WO6CfBSVN8mjOWP8DG0phkYryDJ4aLgkqoUJy5/4f8HspwnFHPYQkEUCcYLjtgzO
V7mc9Gd6xhnVHhEZiaTF4zDo/7YjzIg+DQnQRYsZ9247KRICwFy9/nnCsBjpjodZ
eY9S6bGyHBWYgmxfyzkZtI2UP6o7pUrJJMrzOUUrD893IoXR2VpxJ5GSc3x7qc+h
piA1TgD+4t3bDsYcScQYylQ/hG2eo6LIjYMOuN0QNA7/Cojbro2AY1zQK3rFpGyh
EfRlM3SzlyzC6essdN+0Hr8Au8W51RwhwtPWY0qDazWAtzVVZTChJ1csBKzoR74U
V9v+d4c/BDpFgSTLbIxZKa777N04QUjpZcVyeeBLN+baLWAthMtVt4QJKAsMREkT
39aEgfclx7fwj9Nprzgw
=+UlW
-----END PGP SIGNATURE-----

--KFztAG8eRSV9hGtP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
