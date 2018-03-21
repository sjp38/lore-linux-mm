Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C7C336B000D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 19:16:52 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l9so4106583qkk.17
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 16:16:52 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id o2si1812610qkc.424.2018.03.21.16.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 16:16:52 -0700 (PDT)
Subject: Re: [PATCH 10/15] mm/hmm: do not differentiate between empty entry or
 missing directory v2
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-11-jglisse@redhat.com>
 <4b0da5bb-4e44-798c-f4dd-cabc93cfeb99@nvidia.com>
 <20180321144826.GA3214@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <85bd655c-c161-bf2e-c94f-9bac60483366@nvidia.com>
Date: Wed, 21 Mar 2018 16:16:50 -0700
MIME-Version: 1.0
In-Reply-To: <20180321144826.GA3214@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/21/2018 07:48 AM, Jerome Glisse wrote:
> On Tue, Mar 20, 2018 at 10:24:34PM -0700, John Hubbard wrote:
>> On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>>

<snip>

>>
>> <snip>
>>
>>> @@ -438,7 +423,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>>>  		pfns[i] =3D 0;
>>> =20
>>>  		if (pte_none(pte)) {
>>> -			pfns[i] =3D HMM_PFN_EMPTY;
>>> +			pfns[i] =3D 0;
>>
>> This works, but why not keep HMM_PFN_EMPTY, and just define it as zero?
>> Symbols are better than raw numbers here.
>>
>=20
> The last patch do that so i don't think it is worth respinning
> just to make this intermediate state prettier.
>=20

Yes, you're right, of course. And, no other problems found, so:

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA
