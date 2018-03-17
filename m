Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 412056B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 23:08:15 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a207so5415855qkb.23
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 20:08:15 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id q87si7310207qkl.273.2018.03.16.20.08.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 20:08:14 -0700 (PDT)
Subject: Re: [PATCH 05/14] mm/hmm: use struct for hmm_vma_fault(),
 hmm_vma_get_pfns() parameters
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-6-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9b8ad818-252d-e1f2-0cdb-a7228ccaa392@nvidia.com>
Date: Fri, 16 Mar 2018 20:08:11 -0700
MIME-Version: 1.0
In-Reply-To: <20180316191414.3223-6-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/16/2018 12:14 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20

Hi Jerome,

I failed to find any problems in this patch, so:

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

There are a couple of documentation recommended typo fixes listed
below, which are very minor but as long as I'm here I'll point them out.

> Both hmm_vma_fault() and hmm_vma_get_pfns() were taking a hmm_range
> struct as parameter and were initializing that struct with others of
> their parameters. Have caller of those function do this as they are
> likely to already do and only pass this struct to both function this
> shorten function signature and make it easiers in the future to add

                                         easier

> new parameters by simply adding them to the structure.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/hmm.h | 18 ++++---------
>  mm/hmm.c            | 78 +++++++++++++++++++----------------------------=
------
>  2 files changed, 33 insertions(+), 63 deletions(-)


<snip>
> =20
> =20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 64d9e7dae712..49f0f6b337ed 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -490,11 +490,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
> =20
>  /*
>   * hmm_vma_get_pfns() - snapshot CPU page table for a range of virtual a=
ddresses
> - * @vma: virtual memory area containing the virtual address range
> - * @range: used to track snapshot validity
> - * @start: range virtual start address (inclusive)
> - * @end: range virtual end address (exclusive)
> - * @entries: array of hmm_pfn_t: provided by the caller, filled in by fu=
nction
> + * @range: range being snapshoted and all needed informations

Let's just say this:

* @range: range being snapshotted


<snip>

> @@ -628,11 +617,7 @@ EXPORT_SYMBOL(hmm_vma_range_done);
> =20
>  /*
>   * hmm_vma_fault() - try to fault some address in a virtual address rang=
e
> - * @vma: virtual memory area containing the virtual address range
> - * @range: use to track pfns array content validity
> - * @start: fault range virtual start address (inclusive)
> - * @end: fault range virtual end address (exclusive)
> - * @pfns: array of hmm_pfn_t, only entry with fault flag set will be fau=
lted
> + * @range: range being faulted and all needed informations

Similarly here, let's just write it like this:

* @range: range being faulted


thanks,
--=20
John Hubbard
NVIDIA
