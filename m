Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00B206B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 15:26:55 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id x189so437640030ywe.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 12:26:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y89si31281014qge.17.2016.05.23.12.26.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 12:26:54 -0700 (PDT)
Message-ID: <1464031607.16365.60.camel@redhat.com>
Subject: Re: [PATCH 3/3] mm, thp: make swapin readahead under down_read of
 mmap_sem
From: Rik van Riel <riel@redhat.com>
Date: Mon, 23 May 2016 15:26:47 -0400
In-Reply-To: <20160523190154.GA79357@black.fi.intel.com>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
	 <1464023651-19420-4-git-send-email-ebru.akagunduz@gmail.com>
	 <20160523184246.GE32715@dhcp22.suse.cz>
	 <1464029349.16365.58.camel@redhat.com>
	 <20160523190154.GA79357@black.fi.intel.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-92LJ75Deha+OcI0PJac3"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, hughd@google.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com


--=-92LJ75Deha+OcI0PJac3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-05-23 at 22:01 +0300, Kirill A. Shutemov wrote:
> On Mon, May 23, 2016 at 02:49:09PM -0400, Rik van Riel wrote:
> >=20
> > On Mon, 2016-05-23 at 20:42 +0200, Michal Hocko wrote:
> > >=20
> > > On Mon 23-05-16 20:14:11, Ebru Akagunduz wrote:
> > > >=20
> > > >=20
> > > > Currently khugepaged makes swapin readahead under
> > > > down_write. This patch supplies to make swapin
> > > > readahead under down_read instead of down_write.
> > > You are still keeping down_write. Can we do without it
> > > altogether?
> > > Blocking mmap_sem of a remote proces for write is certainly not
> > > nice.
> > Maybe Andrea can explain why khugepaged requires
> > a down_write of mmap_sem?
> >=20
> > If it were possible to have just down_read that
> > would make the code a lot simpler.
> You need a down_write() to retract page table. We need to make sure
> that
> nobody sees the page table before we can replace it with huge pmd.

Good point.

I guess the alternative is to have the page_table_lock
taken by a helper function (everywhere) that can return
failure if the page table was changed while the caller
was waiting for the lock.

Doable, but a fair amount of code churn.

--=20
All Rights Reversed.


--=-92LJ75Deha+OcI0PJac3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXQ1l3AAoJEM553pKExN6D02wH/2Ol7LLydG17g3sOo6FbsXBT
mkSWOXa0t3UDZupZqFN96EeN6ubnx9NlL2V7s4LrUCH95Ud2bK2sDRQ5EH5Xul/F
94NIJeAW3T49UEsboe5AERXrgHrhVQofwrWFS5WDT9CJ5prajkDTMVdoxnUjxTEq
vkTs504rHGRamuI1c64WDhnc+lWSs+W2xvFScdhachZSY9pEWomxgV3ElSTNs3i+
d2D/be251lRftOkPCjF4XK9hSKGlqUF53xlQ+H09sSFHJOKk65O3o+RxUJtRz+Sq
/95fNM0yN2CfaUX/k0I5R+rz7cm/j85oMv+hcLpPm7ZECXRdjPFfDGSuTM4QmHs=
=W0P3
-----END PGP SIGNATURE-----

--=-92LJ75Deha+OcI0PJac3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
