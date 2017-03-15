Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA0AC6B0038
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 12:01:02 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 68so29291643ioh.4
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:01:02 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0123.outbound.protection.outlook.com. [104.47.37.123])
        by mx.google.com with ESMTPS id u44si936510oth.112.2017.03.15.09.00.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 09:00:56 -0700 (PDT)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v4 05/11] mm: thp: enable thp migration in generic path
Date: Wed, 15 Mar 2017 11:00:52 -0500
Message-ID: <84C15843-6697-42AD-B590-DBB72E672632@cs.rutgers.edu>
In-Reply-To: <CAMuHMdXQqdZpvtv9un8AoNu-9D5Aq+ZdoPjTrCqka1afi5RQsA@mail.gmail.com>
References: <201703150534.RFh2ClRg%fengguang.wu@intel.com>
 <58C866B6.4040800@cs.rutgers.edu>
 <CAMuHMdXQqdZpvtv9un8AoNu-9D5Aq+ZdoPjTrCqka1afi5RQsA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_35421DC6-9F93-4FE9-8CEB-4E393BAC88D3_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: kbuild test robot <lkp@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, dnellans@nvidia.com

--=_MailMate_35421DC6-9F93-4FE9-8CEB-4E393BAC88D3_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 15 Mar 2017, at 4:01, Geert Uytterhoeven wrote:

> On Tue, Mar 14, 2017 at 10:55 PM, Zi Yan <zi.yan@cs.rutgers.edu> wrote:=

>>>>> include/linux/swapops.h:223:2: warning: missing braces around initi=
alizer [-Wmissing-braces]
>>>      return (pmd_t){ 0 };
>>>      ^
>>>    include/linux/swapops.h:223:2: warning: (near initialization for '=
(anonymous).pmd') [-Wmissing-braces]
>>
>> I do not have any warning with gcc 6.3.0. This seems to be a GCC bug
>> (https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D53119).
>
> I guess you need
>
>     return (pmd_t) { { 0, }};
>
> to kill the warning.

Yeah, that should work. I find the same solution from StackOverflow.

Thanks.

--
Best Regards
Yan Zi

--=_MailMate_35421DC6-9F93-4FE9-8CEB-4E393BAC88D3_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYyWU0AAoJEEGLLxGcTqbM3ngIAImIhggnRA9M/OXwo4slVc2V
8iDC1krL5hGgMg2dVRtYzeDjfcGhMDWXAG/3sECdf1g+3a89bQUeL1vbmjElMALW
DxiYo1SUXuYASKd5F8WOh8xKH5FFCCun2JjjHKmVzaUx2zDSENRcJ35KIPdJLppp
RYWTcc3NIcJ5lezVAIh+Jj9fHjMNnNoXB8rVAMVS0hg0J65SNHO9AvV4F3GSBWDr
YpfKv4Q7aui8tdLOBb7HxNTWG/1MGp8sZ9twjzv94XmeKb/OeOd5oIPmKqKIczbJ
eJrOZGZ41c1oH8qi3bBW9kehmHTBo3iFREMJnBOyGmM3OSFCeDaDigP4bT9ZkCE=
=JAwp
-----END PGP SIGNATURE-----

--=_MailMate_35421DC6-9F93-4FE9-8CEB-4E393BAC88D3_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
