Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB196B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 01:55:30 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g5-v6so1801914pgv.12
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 22:55:30 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id o9-v6si49583450plk.434.2018.06.05.22.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 22:55:28 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm, memory_failure: remove a stray tab
Date: Wed, 6 Jun 2018 05:53:38 +0000
Message-ID: <20180606055338.GA18635@hori1.linux.bs1.fc.nec.co.jp>
References: <20180605081616.o2q4wdbvolggefck@kili.mountain>
In-Reply-To: <20180605081616.o2q4wdbvolggefck@kili.mountain>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <BFFD73FB430EE8408B048FE98D958039@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Dan Williams <dan.j.williams@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>

On Tue, Jun 05, 2018 at 11:16:16AM +0300, Dan Carpenter wrote:
> The return statement is indented too far.
>=20
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Thanks!

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index de0bc897d6e7..72cde4b0939e 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1147,7 +1147,7 @@ static unsigned long dax_mapping_size(struct addres=
s_space *mapping,
>  	if (page->mapping !=3D mapping) {
>  		xa_unlock_irq(&mapping->i_pages);
>  		i_mmap_unlock_read(mapping);
> -			return 0;
> +		return 0;
>  	}
>  	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
>  		unsigned long address =3D vma_address(page, vma);
> =
