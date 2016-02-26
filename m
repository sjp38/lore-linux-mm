Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id A7D886B0254
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:52:13 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id y89so66609767qge.2
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 06:52:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 21si13448519qhu.7.2016.02.26.06.52.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 06:52:13 -0800 (PST)
Message-ID: <1456498316.25322.35.camel@redhat.com>
Subject: Re: [RFC v5 0/3] mm: make swapin readahead to gain more thp
 performance
From: Rik van Riel <riel@redhat.com>
Date: Fri, 26 Feb 2016 09:51:56 -0500
In-Reply-To: <alpine.LSU.2.11.1602252151030.9793@eggly.anvils>
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
	 <20150914144106.ee205c3ae3f4ec0e5202c9fe@linux-foundation.org>
	 <alpine.LSU.2.11.1602242301040.6947@eggly.anvils>
	 <1456439750.15821.97.camel@redhat.com> <20160225233017.GA14587@debian>
	 <alpine.LSU.2.11.1602252151030.9793@eggly.anvils>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-FF75zn0upSr67ajfZxRZ"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com


--=-FF75zn0upSr67ajfZxRZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-02-25 at 22:17 -0800, Hugh Dickins wrote:
> On Fri, 26 Feb 2016, Ebru Akagunduz wrote:
> > in Thu, Feb 25, 2016 at 05:35:50PM -0500, Rik van Riel wrote:
>=C2=A0
> > > Am I forgetting anything obvious?
> > >=C2=A0
> > > Is this too aggressive?
> > >=C2=A0
> > > Not aggressive enough?
> > >=C2=A0
> > > Could PGPGOUT + PGSWPOUT be a useful
> > > in-between between just PGSWPOUT or
> > > PGSTEAL_*?
>=20
> I've no idea offhand, would have to study what each of those
> actually means: I'm really not familiar with them myself.

There are a few levels of page reclaim activity:

PGSTEAL_* - any page was reclaimed, this could just
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 be file pages for streaming file =
IO,etc

PGPGOUT =C2=A0 - the VM wrote pages back to disk to reclaim
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 them, this could include file pag=
es

PGSWPOUT =C2=A0- the VM wrote something to swap to reclaim
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memory

I am not sure which level of aggressiveness khugepaged
should check against, but my gut instinct would probably
be the second or third.

--=20
All Rights Reversed.


--=-FF75zn0upSr67ajfZxRZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJW0GaMAAoJEM553pKExN6DUl8IAJ8n2fhcYPqmxEBV8XCv6yan
5EQggYjF9EO4MnwYADEd99lQc7byfI4VMZ4yLt9v7CqTQNWg0BOgzKAqR/zo2tcw
qeGCldpjtYPo3K/yHTS5w0sTzZjXPn4oGGasgcrreC9wZtLkWz3UjZovXYZ5PeDl
zDadO/65MvO8FJo7yWpenB8PNEN55j45crtvnPOoKAnmuPBUHJVnjZnBsWFEMxsW
tOR/DZ/9NVuR2UtwZZulWj7slDlIXbWbR6X1T8k5eUszFM1i+RuNq4U7P8Yg+nIo
O8haqq/+JtmeETQo8iLsg8vS9ONEbmHkdiMpEQpUYRhWy1qZYD+GpMGvCdvfeiM=
=gtHf
-----END PGP SIGNATURE-----

--=-FF75zn0upSr67ajfZxRZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
