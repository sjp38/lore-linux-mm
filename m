Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E16E6B029C
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:01:59 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id n68so27841564itn.4
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 06:01:59 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0115.outbound.protection.outlook.com. [104.47.34.115])
        by mx.google.com with ESMTPS id b29si3524239ioj.4.2016.11.10.06.01.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 06:01:56 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v2 00/12] mm: page migration enhancement for thp
Date: Thu, 10 Nov 2016 09:01:48 -0500
Message-ID: <D34FA575-7C5D-4E9D-B337-A925F1A89C66@cs.rutgers.edu>
In-Reply-To: <20161109235223.GA31285@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5822FB60.5040905@linux.vnet.ibm.com>
 <20161109235223.GA31285@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_0ACBB506-96A6-4514-8595-8A694F6D6551_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

--=_MailMate_0ACBB506-96A6-4514-8595-8A694F6D6551_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 9 Nov 2016, at 18:52, Naoya Horiguchi wrote:

> Hi Anshuman,
>
> On Wed, Nov 09, 2016 at 04:03:04PM +0530, Anshuman Khandual wrote:
>> On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
>>> Hi everyone,
>>>
>>> I've updated thp migration patches for v4.9-rc2-mmotm-2016-10-27-18-2=
7
>>> with feedbacks for ver.1.
>>>
>>> General description (no change since ver.1)
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>
>>> This patchset enhances page migration functionality to handle thp mig=
ration
>>> for various page migration's callers:
>>>  - mbind(2)
>>>  - move_pages(2)
>>>  - migrate_pages(2)
>>>  - cgroup/cpuset migration
>>>  - memory hotremove
>>>  - soft offline
>>>
>>> The main benefit is that we can avoid unnecessary thp splits, which h=
elps us
>>> avoid performance decrease when your applications handles NUMA optimi=
zation on
>>> their own.
>>>
>>> The implementation is similar to that of normal page migration, the k=
ey point
>>> is that we modify a pmd to a pmd migration entry in swap-entry like f=
ormat.
>>
>> Will it be better to have new THP_MIGRATE_SUCCESS and THP_MIGRATE_FAIL=

>> VM events to capture how many times the migration worked without first=

>> splitting the huge page and how many time it did not work ?
>
> Thank you for the suggestion.
> I think that's helpful, so will try it in next version.
>
>> Also do you
>> have a test case which demonstrates this THP migration and kind of sho=
ws
>> its better than the present split and move method ?
>
> I don't have test cases which compare thp migration and split-then-migr=
ation
> with some numbers. Maybe measuring/comparing the overhead of migration =
is
> a good start point, although I think the real benefit of thp migration =
comes
> from workload "after migration" by avoiding thp split.

Migrating 4KB pages has much lower (~1/3) throughput than 2MB pages.

What I get is that on average it takes 1987.38 us to migrate 512 4KB page=
s and
                                       658.54  us to migrate 1   2MB page=
=2E

I did the test in a two-socket Intel Xeon E5-2640v4 box. I used migrate_p=
ages()
system call to migrate pages. MADV_NOHUGEPAGE and MADV_HUGEPAGE are used =
to
make 4KB and 2MB pages and each page=E2=80=99s flags are checked to make =
sure the page
size is 4KB or 2MB THP.

There is no split page. But the page migration time already tells the sto=
ry.

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_0ACBB506-96A6-4514-8595-8A694F6D6551_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYJH3NAAoJEEGLLxGcTqbMz1oH/2Nnz4H2znvV1IbF4ZbQMgZq
AaI60jTj/aUgeE1YAlAfc1F4z0XDAnWWOGdE4poCcbT+PlHUPqTbqe0nyRP+io1B
YFyTO0/dEHxBqjju7vBH/vT9TTNuAp8WNFqmmKedeJqS7k2xh2GACwjfZvG2i7Xg
hbHH2SNkubVWc5KttHwoo+NH4KtNycLP4qOMoLsDSjeOaZJaMQAz80SrPrcdrHPm
HyKS5zKp8mMKoxBiCz6t+gBAsHQkL39kqDzCSRXpgvU6VeGB6RMPAnxHgKIc9dnw
3DghqiXEVGaDlIsq7ZN2705N/s0Yr0KoqY//74mwuFVu2JVdI3fkBPf8ORNkpoM=
=33eG
-----END PGP SIGNATURE-----

--=_MailMate_0ACBB506-96A6-4514-8595-8A694F6D6551_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
