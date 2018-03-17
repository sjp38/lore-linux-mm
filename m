Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 237BA6B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 23:59:56 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id p11so8038830qtg.19
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 20:59:56 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 96si9287563qtc.419.2018.03.16.20.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 20:59:56 -0700 (PDT)
Subject: Re: [PATCH 07/14] mm/hmm: use uint64_t for HMM pfn instead of
 defining hmm_pfn_t to ulong
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-8-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <e20e4e55-c99b-03c2-0bcf-4167d583dcbe@nvidia.com>
Date: Fri, 16 Mar 2018 20:59:49 -0700
MIME-Version: 1.0
In-Reply-To: <20180316191414.3223-8-jglisse@redhat.com>
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

This one looks great. A couple of trivial typo fixes are listed below.

You can add:

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

> All device driver we care about are using 64bits page table entry. In
> order to match this and to avoid useless define convert all HMM pfn to
> directly use uint64_t. It is a first step on the road to allow driver
> to directly use pfn value return by HMM (saving memory and CPU cycles
> use for convertion between the two).

  used for conversion
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/hmm.h | 46 +++++++++++++++++++++-------------------------
>  mm/hmm.c            | 26 +++++++++++++-------------
>  2 files changed, 34 insertions(+), 38 deletions(-)
>=20

<snip>

> @@ -104,14 +100,14 @@ typedef unsigned long hmm_pfn_t;
>  #define HMM_PFN_SHIFT 6
> =20
>  /*
> - * hmm_pfn_t_to_page() - return struct page pointed to by a valid hmm_pf=
n_t
> - * @pfn: hmm_pfn_t to convert to struct page
> - * Returns: struct page pointer if pfn is a valid hmm_pfn_t, NULL otherw=
ise
> + * hmm_pfn_to_page() - return struct page pointed to by a valid HMM pfn
> + * @pfn: HMM pfn value to get corresponding struct page from
> + * Returns: struct page pointer if pfn is a valid HMM pfn, NULL otherwis=
e
>   *
> - * If the hmm_pfn_t is valid (ie valid flag set) then return the struct =
page
> - * matching the pfn value stored in the hmm_pfn_t. Otherwise return NULL=
.
> + * If the uint64_t is valid (ie valid flag set) then return the struct p=
age

      If the HMM pfn is valid

<snip>

> =20
> @@ -634,8 +634,8 @@ EXPORT_SYMBOL(hmm_vma_range_done);
>   * This is similar to a regular CPU page fault except that it will not t=
rigger
>   * any memory migration if the memory being faulted is not accessible by=
 CPUs.
>   *
> - * On error, for one virtual address in the range, the function will set=
 the
> - * hmm_pfn_t error flag for the corresponding pfn entry.
> + * On error, for one virtual address in the range, the function will mar=
k the
> + * correspond HMM pfn entry with error flag.

      corresponding HMM pfn entry with an error flag.

thanks,
--=20
John Hubbard
NVIDIA
