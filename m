Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D37116B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 22:10:36 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d127so960775pga.11
        for <linux-mm@kvack.org>; Tue, 30 May 2017 19:10:36 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id 19si14919864pgc.344.2017.05.30.19.10.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 19:10:36 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id f127so141136pgc.2
        for <linux-mm@kvack.org>; Tue, 30 May 2017 19:10:36 -0700 (PDT)
Date: Wed, 31 May 2017 12:10:24 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [HMM 02/15] mm/hmm: heterogeneous memory management (HMM for
 short) v4
Message-ID: <20170531121024.4e14f91a@firefly.ozlabs.ibm.com>
In-Reply-To: <20170524172024.30810-3-jglisse@redhat.com>
References: <20170524172024.30810-1-jglisse@redhat.com>
	<20170524172024.30810-3-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Wed, 24 May 2017 13:20:11 -0400
J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> wrote:

> HMM provides 3 separate types of functionality:
>     - Mirroring: synchronize CPU page table and device page table
>     - Device memory: allocating struct page for device memory
>     - Migration: migrating regular memory to device memory
>=20
> This patch introduces some common helpers and definitions to all of
> those 3 functionality.
>=20
> Changed since v3:
>   - Unconditionaly build hmm.c for static keys
> Changed since v2:
>   - s/device unaddressable/device private
> Changed since v1:
>   - Kconfig logic (depend on x86-64 and use ARCH_HAS pattern)
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> ---

It would be nice to explain a bit of how hmm_pfn_t bits work with pfn
and find out what we need from an arch to support HMM.


Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
