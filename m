Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A43796B0025
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:40:49 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id k22so7585732qtj.0
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:40:49 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id w63si1571046qkd.397.2018.03.16.14.40.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:40:48 -0700 (PDT)
Subject: Re: [PATCH 02/14] mm/hmm: fix header file if/else/endif maze
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-3-jglisse@redhat.com>
 <20180316140959.b603888e2a9ba2e42e56ba1f@linux-foundation.org>
 <20180316211801.GB4861@redhat.com>
 <20180316143537.0d49a76ec48ec0ab034af93b@linux-foundation.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <48f31a69-c4f8-5e50-00e8-0def08f750a3@nvidia.com>
Date: Fri, 16 Mar 2018 14:40:47 -0700
MIME-Version: 1.0
In-Reply-To: <20180316143537.0d49a76ec48ec0ab034af93b@linux-foundation.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>

On 03/16/2018 02:35 PM, Andrew Morton wrote:
> On Fri, 16 Mar 2018 17:18:02 -0400 Jerome Glisse <jglisse@redhat.com> wro=
te:
>=20
>> On Fri, Mar 16, 2018 at 02:09:59PM -0700, Andrew Morton wrote:
>>> On Fri, 16 Mar 2018 15:14:07 -0400 jglisse@redhat.com wrote:
>>>
>>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>>>
>>>> The #if/#else/#endif for IS_ENABLED(CONFIG_HMM) were wrong.
>>>
>>> "were wrong" is not a sufficient explanation of the problem, especially
>>> if we're requesting a -stable backport.  Please fully describe the
>>> effects of a bug when fixing it?
>>
>> Build issue (compilation failure) if you have multiple includes of
>> hmm.h through different headers is the most obvious issue. So it
>> will be very obvious with any big driver that include the file in
>> different headers.
>=20
> That doesn't seem to warrant a -stable backport?  The developer of such
> a driver will simply fix the headers?

Right. For this patch, I would strongly request a -stable backport.  It's=20
really going to cause problems if anyone tries to use -stable with HMM,
without this fix.

thanks,
--=20
John Hubbard
NVIDIA

>=20
>> I can respin with that. Sorry again for not being more explanatory
>> it is always hard for me to figure what is not obvious to others.
>=20
> I updated the changelog, no respin needed.
>=20
