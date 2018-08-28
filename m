Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6B036B4694
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 11:54:36 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id e3-v6so1626475qkj.17
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 08:54:36 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 2-v6sor719087qvq.12.2018.08.28.08.54.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 08:54:36 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH 4/7] mm/hmm: properly handle migration pmd
Date: Tue, 28 Aug 2018 11:54:33 -0400
Message-ID: <44C89854-FE83-492F-B6BB-CF54B77233CF@cs.rutgers.edu>
In-Reply-To: <20180828154555.GS10223@dhcp22.suse.cz>
References: <20180824192549.30844-1-jglisse@redhat.com>
 <20180824192549.30844-5-jglisse@redhat.com>
 <0560A126-680A-4BAE-8303-F1AB34BE4BA5@cs.rutgers.edu>
 <20180828152414.GQ10223@dhcp22.suse.cz> <20180828153658.GA4029@redhat.com>
 <20180828154206.GR10223@dhcp22.suse.cz>
 <20180828154555.GS10223@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_1C393E60-603F-4FB6-924E-D18DABFB8B6D_=";
 micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_1C393E60-603F-4FB6-924E-D18DABFB8B6D_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Michal,

On 28 Aug 2018, at 11:45, Michal Hocko wrote:

> On Tue 28-08-18 17:42:06, Michal Hocko wrote:
>> On Tue 28-08-18 11:36:59, Jerome Glisse wrote:
>>> On Tue, Aug 28, 2018 at 05:24:14PM +0200, Michal Hocko wrote:
>>>> On Fri 24-08-18 20:05:46, Zi Yan wrote:
>>>> [...]
>>>>>> +	if (!pmd_present(pmd)) {
>>>>>> +		swp_entry_t entry =3D pmd_to_swp_entry(pmd);
>>>>>> +
>>>>>> +		if (is_migration_entry(entry)) {
>>>>>
>>>>> I think you should check thp_migration_supported() here, since PMD =
migration is only enabled in x86_64 systems.
>>>>> Other architectures should treat PMD migration entries as bad.
>>>>
>>>> How can we have a migration pmd entry when the migration is not
>>>> supported?
>>>
>>> Not sure i follow here, migration can happen anywhere (assuming
>>> that something like compaction is active or numa or ...). So this
>>> code can face pmd migration entry on architecture that support
>>> it. What is missing here is thp_migration_supported() call to
>>> protect the is_migration_entry() to avoid false positive on arch
>>> which do not support thp migration.
>>
>> I mean that architectures which do not support THP migration shouldn't=

>> ever see any migration entry. So is_migration_entry should be always
>> false. Or do I miss something?
>
> And just to be clear. thp_migration_supported should be checked only
> when we actually _do_ the migration or evaluate migratability of the
> page. We definitely do want to sprinkle this check to all places where
> is_migration_entry is checked.

is_migration_entry() is a general check for swp_entry_t, so it can return=

true even if THP migration is not enabled. is_pmd_migration_entry() alway=
s
returns false when THP migration is not enabled.

So the code can be changed in two ways, either replacing is_migration_ent=
ry()
with is_pmd_migration_entry() or adding thp_migration_supported() check
like Jerome did.

Does this clarify your question?

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_1C393E60-603F-4FB6-924E-D18DABFB8B6D_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBAgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAluFcDkWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzFPqB/9X0AVYtyFl6ZEWgDJsRmWv5Kpb
fV8J8/qvQFyRcqFuGTCwSLg0aYCt6juJTd4nVoKvXdSKlzvD0gYgLC4y/qzrVrMq
H8/7OBX56gzUzkdvb36K67sYV40SI+vWZvpFt0+zNKYY24wdsMH6tInClmMjpqdW
T4uNwrjkRvsOZ/uvDYmnhNbSqAuY06YkgjVfpC2K4/lU9vq67OjodtlXg6KMYX2G
d8frSR81iRKedlirvVdGkjuqIgncmFLwxhFPAXfNWooU8Mn4BMD0zFnPS9dHUrik
PY1nSix9Xtb0S3+P9rEU/dYf08imf9EeCtMDuSykMlcteDwNQUsFx/rThqM5
=8vBu
-----END PGP SIGNATURE-----

--=_MailMate_1C393E60-603F-4FB6-924E-D18DABFB8B6D_=--
