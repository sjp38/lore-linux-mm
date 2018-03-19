Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7948A6B0008
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:09:11 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c9so12962908qth.16
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 16:09:11 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id o126si318869qkf.145.2018.03.19.16.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 16:09:10 -0700 (PDT)
Subject: Re: [PATCH 10/14] mm/hmm: rename HMM_PFN_DEVICE_UNADDRESSABLE to
 HMM_PFN_DEVICE_PRIVATE
References: <20180316203552.4155-1-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <56e72cd2-9730-f031-ae75-915b94103588@nvidia.com>
Date: Mon, 19 Mar 2018 16:09:08 -0700
MIME-Version: 1.0
In-Reply-To: <20180316203552.4155-1-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/16/2018 01:35 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> Make naming consistent accross code, DEVICE_PRIVATE is the name use
> outside HMM code so use that one.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/hmm.h | 4 ++--
>  mm/hmm.c            | 2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)

Seems entirely harmless. :)

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 6d2b6bf6da4b..78018b3e7a9f 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -88,13 +88,13 @@ struct hmm;
>   *      result of vm_insert_pfn() or vm_insert_page(). Therefore, it sho=
uld not
>   *      be mirrored by a device, because the entry will never have HMM_P=
FN_VALID
>   *      set and the pfn value is undefined.
> - * HMM_PFN_DEVICE_UNADDRESSABLE: unaddressable device memory (ZONE_DEVIC=
E)
> + * HMM_PFN_DEVICE_PRIVATE: unaddressable device memory (ZONE_DEVICE)
>   */
>  #define HMM_PFN_VALID (1 << 0)
>  #define HMM_PFN_WRITE (1 << 1)
>  #define HMM_PFN_ERROR (1 << 2)
>  #define HMM_PFN_SPECIAL (1 << 3)
> -#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 4)
> +#define HMM_PFN_DEVICE_PRIVATE (1 << 4)
>  #define HMM_PFN_SHIFT 5
> =20
>  /*
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 2118e42cb838..857eec622c98 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -429,7 +429,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  					pfns[i] |=3D HMM_PFN_WRITE;
>  				} else if (write_fault)
>  					goto fault;
> -				pfns[i] |=3D HMM_PFN_DEVICE_UNADDRESSABLE;
> +				pfns[i] |=3D HMM_PFN_DEVICE_PRIVATE;
>  			} else if (is_migration_entry(entry)) {
>  				if (hmm_vma_walk->fault) {
>  					pte_unmap(ptep);
>=20

thanks,
--=20
John Hubbard
NVIDIA
