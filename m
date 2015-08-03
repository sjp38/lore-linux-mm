Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id E51ED9003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 07:41:01 -0400 (EDT)
Received: by qgeh16 with SMTP id h16so85612428qge.3
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 04:41:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i187si16635081qhc.20.2015.08.03.04.41.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 04:41:00 -0700 (PDT)
Message-ID: <55BF5340.4080008@redhat.com>
Date: Mon, 03 Aug 2015 13:40:48 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 25/36] mm, thp: remove infrastructure for handling splitting
 PMDs
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-26-git-send-email-kirill.shutemov@linux.intel.com> <55BB8DB2.9010804@redhat.com> <20150803104110.GA25034@node.dhcp.inet.fi>
In-Reply-To: <20150803104110.GA25034@node.dhcp.inet.fi>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="duiOcwInaXQn40A3R4tvh6CbkIdrogXvi"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--duiOcwInaXQn40A3R4tvh6CbkIdrogXvi
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 08/03/2015 12:41 PM, Kirill A. Shutemov wrote:
> On Fri, Jul 31, 2015 at 05:01:06PM +0200, Jerome Marchand wrote:
>> On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
>>> @@ -1616,23 +1605,14 @@ int change_huge_pmd(struct vm_area_struct *vm=
a, pmd_t *pmd,
>>>   * Note that if it returns 1, this routine returns without unlocking=
 page
>>>   * table locks. So callers must unlock them.
>>>   */
>>
>> The comment above should be updated.
>=20
> Like this?

Yes. Thanks.

>=20
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index d32277463932..78a6c7cdf8f7 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1627,11 +1627,10 @@ int change_huge_pmd(struct vm_area_struct *vma,=
 pmd_t *pmd,
>  }
> =20
>  /*
> - * Returns 1 if a given pmd maps a stable (not under splitting) thp.
> - * Returns -1 if it maps a thp under splitting. Returns 0 otherwise.
> + * Returns true if a given pmd maps a thp, false otherwise.
>   *
> - * Note that if it returns 1, this routine returns without unlocking p=
age
> - * table locks. So callers must unlock them.
> + * Note that if it returns true, this routine returns without unlockin=
g page
> + * table lock. So callers must unlock it.
>   */
>  bool __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
>  		spinlock_t **ptl)
>=20



--duiOcwInaXQn40A3R4tvh6CbkIdrogXvi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVv1NEAAoJEHTzHJCtsuoC/UEH/i1nFIaNWqqsG1jodKuBtois
ywnvcAxRVWce6O7KcyjCrQjqoZ+0xc/NLHYwEsSuncNYYLsllOKdy5+0GAJlYSfD
k4Kg9m1iILb4bQTgfahKG46egEGmPqqhLnjlXC2t/Bk37wrSKUbr2lTGRIa7RaGl
ddvbnC+WMtzy/hJgg1maSjXfjKjKb9zy4s4g1ewhwKImXd8JVB29iu9LJadwxLCt
2mzu2SFUmSsCfLH6AnG5wSDepMr71kXGD09fQ7vsXbvBzUkBaqTFXT+9zEjvjshn
LgcREuQnjd2daBSsRJVbZlfBEKKVZm5OsMMk5QkoZn9OrYbIcfyk9fAktEE0cyM=
=Ukhq
-----END PGP SIGNATURE-----

--duiOcwInaXQn40A3R4tvh6CbkIdrogXvi--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
