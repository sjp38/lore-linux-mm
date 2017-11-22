Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E1CFC6B02A0
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 10:09:09 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 27so14718695pft.8
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 07:09:09 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0110.outbound.protection.outlook.com. [104.47.40.110])
        by mx.google.com with ESMTPS id 3si14153035plm.80.2017.11.22.07.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 07:09:08 -0800 (PST)
Message-ID: <5A159319.6070403@cs.rutgers.edu>
Date: Wed, 22 Nov 2017 10:09:13 -0500
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: migrate: fix an incorrect call of prep_transhuge_page()
References: <20171121021855.50525-1-zi.yan@sent.com> <20171122085416.ycrvahu2bznlx37s@dhcp22.suse.cz> <20171122134059.fmyambktkel4e3zq@dhcp22.suse.cz> <5A158D22.3040609@cs.rutgers.edu> <20171122145307.52klaq4ouorngsss@dhcp22.suse.cz>
In-Reply-To: <20171122145307.52klaq4ouorngsss@dhcp22.suse.cz>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------enig7E25352A517722FE458B5745"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zi Yan <zi.yan@sent.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Reale <ar@linux.vnet.ibm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, stable@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7E25352A517722FE458B5745
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Michal Hocko wrote:
> On Wed 22-11-17 09:43:46, Zi Yan wrote:
>>
>> Michal Hocko wrote:
>>> On Wed 22-11-17 09:54:16, Michal Hocko wrote:
>>>> On Mon 20-11-17 21:18:55, Zi Yan wrote:
>>> [...]
>>>>> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
>>>>> index 895ec0c4942e..a2246cf670ba 100644
>>>>> --- a/include/linux/migrate.h
>>>>> +++ b/include/linux/migrate.h
>>>>> @@ -54,7 +54,7 @@ static inline struct page *new_page_nodemask(stru=
ct page *page,
>>>>>  	new_page =3D __alloc_pages_nodemask(gfp_mask, order,
>>>>>  				preferred_nid, nodemask);
>>>>> =20
>>>>> -	if (new_page && PageTransHuge(page))
>>>>> +	if (new_page && PageTransHuge(new_page))
>>>>>  		prep_transhuge_page(new_page);
>>>> I would keep the two checks consistent. But that leads to a more
>>>> interesting question. new_page_nodemask does
>>>>
>>>> 	if (thp_migration_supported() && PageTransHuge(page)) {
>>>> 		order =3D HPAGE_PMD_ORDER;
>>>> 		gfp_mask |=3D GFP_TRANSHUGE;
>>>> 	}
>>> And one more question/note. Why do we need thp_migration_supported
>>> in the first place? 9c670ea37947 ("mm: thp: introduce
>>> CONFIG_ARCH_ENABLE_THP_MIGRATION") says
>>> : Introduce CONFIG_ARCH_ENABLE_THP_MIGRATION to limit thp migration
>>> : functionality to x86_64, which should be safer at the first step.
>>>
>>> but why is unsafe to enable the feature on other arches which support=

>>> THP? Is there any plan to do the next step and remove this config
>>> option?
>> Because different architectures have their own way of specifying a swa=
p
>> entry. This means, to support THP migration, each architecture needs t=
o
>> add its own __pmd_to_swp_entry() and __swp_entry_to_pmd(), which are
>> used for arch-independent pmd_to_swp_entry() and swp_entry_to_pmd().
>=20
> I understand that part. But this smells like a matter of coding, no?
> I was suprised to see the note about safety which didn't make much sens=
e
> to me.

And testing as well. I had powerpc book3s support in my initial patch
submission, but removed it because I do not have access to the powerpc
machine any more. I also tried ARM64, which seems working by adding the
code, but I have no hardware to test it now.

Any suggestions?

--=20
Best Regards,
Yan Zi


--------------enig7E25352A517722FE458B5745
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJaFZMZAAoJEEGLLxGcTqbM1y4IAJDtvB1GGuQgmdJq+GALYpaw
nRcifkoS1YHwxUHEpyAGH3KX/X2GVy0ZkC8Ix4XaqQ848zKEXk8ZEtkFn2EH7fzj
pOB5cTKXTkpvMc5qHl44c7QI7ABCwVqo56vyg1aAcXU6grMROzIlLeLFvqYTpUPH
L/0UYR5fHFJIcJr8HAa3oDg4YIVWYNNfGcDdrx9ZS8tHqJCOiwF8vWAEFCTAlQPD
fBeumd2bJrzuJSzVl77wBBxX1v9OU/y0r2r2noe2sArvM2fk/jZEzdSwEMxPBdWR
vcXUOB7SQDjpSsQkmzJbRi0DguyUzZbc0XXlhUpUrqqR0uP97SNPClGd1m0kcZ8=
=+pVC
-----END PGP SIGNATURE-----

--------------enig7E25352A517722FE458B5745--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
