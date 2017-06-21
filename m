Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3ABED6B0279
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 15:59:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e26so167806445pfk.12
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 12:59:33 -0700 (PDT)
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com. [15.233.44.26])
        by mx.google.com with ESMTPS id b10si9182847pfj.265.2017.06.21.12.59.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 12:59:32 -0700 (PDT)
From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: RE: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings of
 poison pages
Date: Wed, 21 Jun 2017 19:59:07 +0000
Message-ID: <AT5PR84MB0082333B55A6823A73C28989ABDA0@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
References: <20170616190200.6210-1-tony.luck@intel.com>
 <20170619180147.qolal6mz2wlrjbxk@pd.tnic>
 <20170621174740.npbtg2e4o65tyrss@intel.com>
In-Reply-To: <20170621174740.npbtg2e4o65tyrss@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Borislav Petkov <bp@suse.de>
Cc: Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Yazen Ghannam <yazen.ghannam@amd.com>, "'dan.j.williams@intel.com'" <dan.j.williams@intel.com>, "Kani, Toshimitsu" <toshi.kani@hpe.com>, "Vaden, Tom (HPE Server OS Architecture)" <tom.vaden@hpe.com>

> +	decoy_addr =3D (pfn << PAGE_SHIFT) + (PAGE_OFFSET ^ BIT(63));
> +#else
> +#error "no unused virtual bit available"
> +#endif
> +
> +	if (set_memory_np(decoy_addr, 1))
> +		pr_warn("Could not invalidate pfn=3D0x%lx from 1:1 map \n", pfn);

Does this patch handle breaking up 512 GiB, 1 GiB or 2 MiB page mappings
if it's just trying to mark a 4 KiB page as bad?

Although the kernel doesn't use MTRRs itself anymore, what if the system
BIOS still uses them for some memory regions, and the bad address falls in
an MTRR region?

---
Robert Elliott, HPE Persistent Memory




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
