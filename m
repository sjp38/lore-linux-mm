Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 206A66B0292
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 03:18:34 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id l145so57776505ita.14
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 00:18:34 -0700 (PDT)
Received: from fldsmtpe03.verizon.com (fldsmtpe03.verizon.com. [140.108.26.142])
        by mx.google.com with ESMTPS id g17si1649217ita.17.2017.06.02.00.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 00:18:33 -0700 (PDT)
From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: Re: [PATCH 1/9] mm: introduce kv[mz]alloc helpers
Date: Fri, 2 Jun 2017 07:17:22 +0000
Message-ID: <20170602071718.zk3ujm64xesoqyrr@sasha-lappy>
References: <20170306103032.2540-1-mhocko@kernel.org>
 <20170306103032.2540-2-mhocko@kernel.org>
In-Reply-To: <20170306103032.2540-2-mhocko@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <297D65ED0E8FE949BD99714067205F20@vzwcorp.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, John Hubbard <jhubbard@nvidia.com>, Andreas Dilger <adilger@dilger.ca>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Mar 06, 2017 at 11:30:24AM +0100, Michal Hocko wrote:
> +void *kvmalloc_node(size_t size, gfp_t flags, int node)
> +{
> +	gfp_t kmalloc_flags =3D flags;
> +	void *ret;
> +
> +	/*
> +	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tabl=
es)
> +	 * so the given set of flags has to be compatible.
> +	 */
> +	WARN_ON_ONCE((flags & GFP_KERNEL) !=3D GFP_KERNEL);

Hm, there are quite a few locations in the kernel that do something like:

	__vmalloc(len, GFP_NOFS, PAGE_KERNEL);

According to your patch, vmalloc can't really do GFP_NOFS, right?

--=20

Thanks,
Sasha=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
