Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 98D336B0033
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 15:59:31 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id k56so113281qtc.1
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 12:59:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p64si4360199qkc.349.2017.10.03.12.59.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 12:59:30 -0700 (PDT)
Message-ID: <1507060767.10046.23.camel@redhat.com>
Subject: Re: [PATCHv3] mm: Account pud page tables
From: Rik van Riel <riel@redhat.com>
Date: Tue, 03 Oct 2017 15:59:27 -0400
In-Reply-To: <20171002080427.3320-1-kirill.shutemov@linux.intel.com>
References: <20171002080427.3320-1-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-aZHpOY31/K4vWS9OysXf"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>


--=-aZHpOY31/K4vWS9OysXf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2017-10-02 at 11:04 +0300, Kirill A. Shutemov wrote:
> On machine with 5-level paging support a process can allocate
> significant amount of memory and stay unnoticed by oom-killer and
> memory cgroup. The trick is to allocate a lot of PUD page tables.
> We don't account PUD page tables, only PMD and PTE.
>=20
> We already addressed the same issue for PMD page tables, see
> dc6c9a35b66b ("mm: account pmd page tables to the process").
> Introduction 5-level paging bring the same issue for PUD page tables.
>=20
> The patch expands accounting to PUD level.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
>=20

Acked-by: Rik van Riel <riel@redhat.com>

--=20
All rights reversed
--=-aZHpOY31/K4vWS9OysXf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZ0+wfAAoJEM553pKExN6DTmsIALbhgql537uDpwzR0VdB9wv2
+gYVGvKiTRqrmD24qw6XV+lZLj2svM48/1+fSMrdz/GYz3xQnj9qVUegexTKU6Jq
pmZR4l7/gQPjybR/sVqpXLfzzr1HH51vbKppB2diPMs2c/BjURPmIXep34hnIgU5
GQ2flsqcMSAM7NugItC0HFXxgr++u6fosHYeIN7c7u+1+7LMi4THnPMOd15wcFcr
Z9Hqz0JzkuznJ1s3wyJaA2+Vu1o93g3D/hbIz9xhCU/n5sI4uhV2sIBt24Q9YEMy
8sYSrpT+Mq4ZOg8DIpiFdMo4fbqdnKfflp/048utIDCGsTjzlmzPUPfhWbrfO+0=
=geub
-----END PGP SIGNATURE-----

--=-aZHpOY31/K4vWS9OysXf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
