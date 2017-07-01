Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 94E1E2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 22:06:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v26so81685872pfa.0
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 19:06:54 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id s132si6944229pgc.391.2017.06.30.19.06.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 19:06:53 -0700 (PDT)
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
From: Evgeny Baskakov <ebaskakov@nvidia.com>
Message-ID: <c0686055-3a18-2ef1-8da3-646056026b8e@nvidia.com>
Date: Fri, 30 Jun 2017 19:06:51 -0700
MIME-Version: 1.0
In-Reply-To: <20170701005749.GA7232@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On 6/30/17 5:57 PM, Jerome Glisse wrote:

> On Fri, Jun 30, 2017 at 04:19:25PM -0700, Evgeny Baskakov wrote:
>> Hi Jerome,
>>
>> It seems that the kernel can pass 0 in src_pfns for pages that it cannot
>> migrate (i.e. the kernel knows that they cannot migrate prior to calling
>> alloc_and_copy).
>>
>> So, a zero in src_pfns can mean either "the page is not allocated yet" o=
r
>> "the page cannot migrate".
>>
>> Can migrate_vma set the MIGRATE_PFN_MIGRATE flag for not allocated pages=
? On
>> the driver side it is difficult to differentiate between the cases.
> So this is what is happening in v24. For thing that can not be migrated y=
ou
> get 0 and for things that are not allocated you get MIGRATE_PFN_MIGRATE l=
ike
> the updated comments in migrate.h explain.
>
> Cheers,
> J=C3=A9r=C3=B4me

Yes, I see the updated documentation in migrate.h. The issue seems to be go=
ne now in v24.

Thanks!

Evgeny Baskakov
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
