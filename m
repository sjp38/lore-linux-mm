Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBAF06B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 19:05:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x63so109036964pfx.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 16:05:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 4si6619711plh.326.2017.03.16.16.05.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 16:05:22 -0700 (PDT)
Date: Thu, 16 Mar 2017 16:05:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [HMM 07/16] mm/migrate: new memory migration helper for use
 with device memory v4
Message-Id: <20170316160520.d03ac02474cad6d2c8eba9bc@linux-foundation.org>
In-Reply-To: <1489680335-6594-8-git-send-email-jglisse@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
	<1489680335-6594-8-git-send-email-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Thu, 16 Mar 2017 12:05:26 -0400 J=E9r=F4me Glisse <jglisse@redhat.com> w=
rote:

> +static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
> +{
> +	if (!(mpfn & MIGRATE_PFN_VALID))
> +		return NULL;
> +	return pfn_to_page(mpfn & MIGRATE_PFN_MASK);
> +}

i386 allnoconfig:

In file included from mm/page_alloc.c:61:
./include/linux/migrate.h: In function 'migrate_pfn_to_page':
./include/linux/migrate.h:139: warning: left shift count >=3D width of type
./include/linux/migrate.h:141: warning: left shift count >=3D width of type
./include/linux/migrate.h: In function 'migrate_pfn_size':
./include/linux/migrate.h:146: warning: left shift count >=3D width of type

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
