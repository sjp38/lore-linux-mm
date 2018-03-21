Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 718E16B0022
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:36:04 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m15so4052206qke.16
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:36:04 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id j60si3018858qtb.451.2018.03.21.15.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 15:36:03 -0700 (PDT)
Subject: Re: [PATCH 13/15] mm/hmm: factor out pte and pmd handling to simplify
 hmm_vma_walk_pmd()
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-14-jglisse@redhat.com>
 <e0fd4348-8b8c-90b2-a9d8-91a30768fddc@nvidia.com>
 <20180321150819.GC3214@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <6ded8a12-1522-3270-602c-bafc7e823758@nvidia.com>
Date: Wed, 21 Mar 2018 15:36:01 -0700
MIME-Version: 1.0
In-Reply-To: <20180321150819.GC3214@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/21/2018 08:08 AM, Jerome Glisse wrote:
> On Tue, Mar 20, 2018 at 10:07:29PM -0700, John Hubbard wrote:
>> On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>

<snip>
=20
>>> +static int hmm_vma_handle_pmd(struct mm_walk *walk,
>>> +			      unsigned long addr,
>>> +			      unsigned long end,
>>> +			      uint64_t *pfns,
>>
>> Hi Jerome,
>>
>> Nice cleanup, it makes it much easier to follow the code now.
>>
>> Let's please rename the pfns argument above to "pfn", because in this
>> helper (and the _pte helper too), there is only one pfn involved, rather
>> than an array of them.
>=20
> This is only true to handle_pte, for handle_pmd it will go over several
> pfn entries. But they will all get fill with same value modulo pfn which
> will increase monotically (ie same flag as pmd permissions apply to all
> entries).

oops, yes you are right about handle_pmd.

>=20
> Note sure s/pfns/pfn for hmm_vma_handle_pte() warrant a respin.

Probably not, unless there is some other reason to respin. Anyway, this pat=
ch
looks good either way, I think, so you can still add:

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA
