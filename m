Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 405926B0008
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:12:13 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 41so13009272qtp.8
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 16:12:13 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id y7si383863qtn.239.2018.03.19.16.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 16:12:12 -0700 (PDT)
Subject: Re: [PATCH 11/14] mm/hmm: move hmm_pfns_clear() closer to where it is
 use
References: <20180316203552.4155-1-jglisse@redhat.com>
 <20180316203552.4155-2-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <80d6ed4e-3e7a-ef22-c931-79491eeedbe7@nvidia.com>
Date: Mon, 19 Mar 2018 16:12:10 -0700
MIME-Version: 1.0
In-Reply-To: <20180316203552.4155-2-jglisse@redhat.com>
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
> Move hmm_pfns_clear() closer to where it is use to make it clear it
> is not use by page table walkers.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  mm/hmm.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 857eec622c98..3a708f500b80 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -297,14 +297,6 @@ static int hmm_pfns_bad(unsigned long addr,
>  	return 0;
>  }
> =20
> -static void hmm_pfns_clear(uint64_t *pfns,
> -			   unsigned long addr,
> -			   unsigned long end)
> -{
> -	for (; addr < end; addr +=3D PAGE_SIZE, pfns++)
> -		*pfns =3D 0;
> -}
> -
>  /*
>   * hmm_vma_walk_hole() - handle a range back by no pmd or no pte
>   * @start: range virtual start address (inclusive)
> @@ -463,6 +455,14 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  	return 0;
>  }
> =20
> +static void hmm_pfns_clear(uint64_t *pfns,
> +			   unsigned long addr,
> +			   unsigned long end)
> +{
> +	for (; addr < end; addr +=3D PAGE_SIZE, pfns++)
> +		*pfns =3D 0;
> +}
> +

Yep, identical, so no functional changes.

>  static void hmm_pfns_special(struct hmm_range *range)
>  {
>  	unsigned long addr =3D range->start, i =3D 0;

thanks,
--=20
John Hubbard
NVIDIA
