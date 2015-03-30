Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E45226B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 10:23:37 -0400 (EDT)
Received: by patj18 with SMTP id j18so12645539pat.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 07:23:37 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id yw6si15037238pab.24.2015.03.30.07.23.36
        for <linux-mm@kvack.org>;
        Mon, 30 Mar 2015 07:23:36 -0700 (PDT)
Date: Mon, 30 Mar 2015 10:23:36 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [patch 1/2] mm, doc: cleanup and clarify munmap behavior for
 hugetlb memory
Message-ID: <20150330142336.GB17678@akamai.com>
References: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com>
 <alpine.LSU.2.11.1503291801400.1052@eggly.anvils>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="H1spWtNR+x+ondvy"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1503291801400.1052@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Davide Libenzi <davidel@xmailserver.org>, Luiz Capitulino <lcapitulino@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-doc@vger.kernel.org


--H1spWtNR+x+ondvy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, 29 Mar 2015, Hugh Dickins wrote:

> On Thu, 26 Mar 2015, David Rientjes wrote:
>=20
> > munmap(2) of hugetlb memory requires a length that is hugepage aligned,
> > otherwise it may fail.  Add this to the documentation.
>=20
> Thanks for taking this on, David.  But although munmap(2) is the one
> Davide called out, it goes beyond that, doesn't it?  To mprotect and
> madvise and ...
>=20
> I don't want to work out the list myself: is_vm_hugetlb_page() is
> special-cased all over, and different syscalls react differently.
>=20
> Which is another reason why, like you, I much prefer not to interfere
> with the long established behavior: it would be very easy to introduce
> bugs and worse inconsistencies.
>=20
> And mprotect(2) is a good example of why we should not mess around
> with the long established API here: changing an mprotect from failing
> on a particular size to acting on a larger size is not a safe change.
>=20
> Eric, I apologize for bringing you in to the discussion, and then
> ignoring your input.  I understand that you would like MAP_HUGETLB
> to behave more understandably.  We can all agree that the existing
> behavior is unsatisfying.  But it's many years too late now to=20
> change it around - and I suspect that a full exercise to do so would
> actually discover some good reasons why the original choices were made.

No worries, my main concern was avoiding the confusion that led me down
the rabbit hole of compaction and mlock.  As long as the documentation,
man pages, and the code all agree I am satisfied.  I would have
preferred to make the code match the docs, but I understand that
changing the code now introduces a risk of breaking userspace.

It is charitable of you to assume that there were good reasons for the
original decision.  But as the author of the code in question, I suspect
the omission was one of my own inexperience.

Eric

--H1spWtNR+x+ondvy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVGVxnAAoJELbVsDOpoOa9CrIQAMYeDPi+++pA2+0B0FROGWAc
IbW3+ObTWxlLz8QxYzVcH/acuMo4fAiEv2Hwa3ErlEKp4x2/emu6OM56iwN9Zbb5
TvaXTHCWpD+qFDcucyfJoTeyLYeJ+eHFr47d247rrCdiHifBnHmACXYopgcHbzVp
gJnI2pSuUpVjo9IHX6aahg8ic0xARC8GmoOF9Vd4X56Z0ocq+MZjS4Jhl7hjDdLK
SDLAxYPPqM7yscgFATxNbjzFr9NhfuW3aV7tmarSaF7HNPbrrevr2THgQlelM+fi
0ZhqaOGcs6ZbAu2bG0x88fhWJal1jrjYsSnZP6WmwVRyJyUK3sJC7JZZsocKtl1s
zjMFozOxz/HljhYV9GEJfSRkTY5MPbxDx2HYCqjo3owW4voEtSMvu3+01KiVfBXs
DwkZHt05iTfNJBoJET5F2fmeEh0yPGbDVMlNdDNMk3sQE9Qz2hJsk81qWhTvZn4l
JV0lWH7rwlGAoi64+ElRHV/XpDMyzyfqdvuH0A6XytgvRvlmVgyDIanhzdNYQpYY
i2AJC2vcAQia/eBfcsKZaDOnx0HfsOGbn3dYcwq6FDPFM9om5sRF8AbJte2rh6W9
/grqdqdIf+d+yosIug7prHdhBitzrf3ihOiRygu+woYTNAUDv4OdgTaPNmpc5u3U
cRQ4rFcxVwGIyM9fefIJ
=csav
-----END PGP SIGNATURE-----

--H1spWtNR+x+ondvy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
