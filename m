Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CCA112806EE
	for <linux-mm@kvack.org>; Fri, 19 May 2017 12:37:47 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q6so63320472pgn.12
        for <linux-mm@kvack.org>; Fri, 19 May 2017 09:37:47 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0098.outbound.protection.outlook.com. [104.47.38.98])
        by mx.google.com with ESMTPS id m10si8676609pln.305.2017.05.19.09.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 May 2017 09:37:46 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v5 02/11] mm: mempolicy: add queue_pages_node_check()
Date: Fri, 19 May 2017 12:37:38 -0400
Message-ID: <35E3E5BA-2745-4710-A348-B6E5D892DA27@cs.rutgers.edu>
In-Reply-To: <20170519160205.hkte6tlw26lfn74h@techsingularity.net>
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-3-zi.yan@sent.com>
 <f7a78cb0-0d91-bdbd-4a38-27f94fcefa8a@linux.vnet.ibm.com>
 <16799a52-8a03-7099-5f95-3016808ae65f@linux.vnet.ibm.com>
 <20170519160205.hkte6tlw26lfn74h@techsingularity.net>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_6FA2AFED-4293-47A6-AA99-5886B7685998_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mhocko@kernel.org, dnellans@nvidia.com

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_6FA2AFED-4293-47A6-AA99-5886B7685998_=
Content-Type: text/plain; markup=markdown
Content-Transfer-Encoding: quoted-printable

On 19 May 2017, at 12:02, Mel Gorman wrote:

> On Fri, May 19, 2017 at 06:43:37PM +0530, Anshuman Khandual wrote:
>> On 04/21/2017 09:34 AM, Anshuman Khandual wrote:
>>> On 04/21/2017 02:17 AM, Zi Yan wrote:
>>>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>>>
>>>> Introduce a separate check routine related to MPOL_MF_INVERT flag.
>>>> This patch just does cleanup, no behavioral change.
>>>
>>> Can you please send it separately first, this should be debated
>>> and merged quickly and not hang on to the series if we have to
>>> respin again.
>>>
>>> Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>>
>> Mel/Andrew,
>>
>> This does not have any functional changes and very much independent.
>> Can this clean up be accepted as is ? In that case we will have to
>> carry one less patch in the series which can make the review process
>> simpler.
>>
>
> As you say, there is no functional change but the helper name is vague
> and gives no hint to what's it's checking for. It's somewhat tolerable =
as
> it is as it's obvious what is being checked but the same is not true wi=
th
> the helper name.
>
> -- =

> Mel Gorman
> SUSE Labs


Does queue_pages_invert_nodemask_check() work? I can change the helper na=
me
in the next version.

--
Best Regards
Yan Zi

--=_MailMate_6FA2AFED-4293-47A6-AA99-5886B7685998_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZHx9SAAoJEEGLLxGcTqbMwVQH/2+Zz2SDHcM0trMNFSkH4w+R
y4lI8+aiDktcc3UOy1kgdY9KvyjZX032Iae0ZstfyNbez1WU5hlN76VtTzyb66xx
koEyzbGxjBMNu9aD0gVrurySbs/X82LrpPuaPjWrB7XIJx1dvHkvt17BAkaH1mhc
rxwO1vr68nOZN1mTdd9zpJJHhwN1zDqx3P6DxeeAUAdASC1LeKLKFeSZF5BMSm/N
b5w0jY8qLQYY6lOC3qGAOG5ggd5gYKMGFWUmlCRn9WMqnFp+GrBO4fJQgEJiXv5B
wKzM7VuUewvfBvm2bEp/WIuHvg2k0/voNz966nJc2xN+Vzcqtu8VpO4Czz2fEeI=
=oU3u
-----END PGP SIGNATURE-----

--=_MailMate_6FA2AFED-4293-47A6-AA99-5886B7685998_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
