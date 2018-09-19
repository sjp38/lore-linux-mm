Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4538E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 18:38:27 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id bh1-v6so3236085plb.15
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 15:38:27 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 13-v6si22184720pgp.563.2018.09.19.15.38.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 15:38:26 -0700 (PDT)
Date: Wed, 19 Sep 2018 16:40:19 -0600
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 6/7] mm/gup: Combine parameters into struct
Message-ID: <20180919224019.GB29003@localhost.localdomain>
References: <20180919210250.28858-1-keith.busch@intel.com>
 <20180919210250.28858-7-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180919210250.28858-7-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Sep 19, 2018 at 03:02:49PM -0600, Keith Busch wrote:
>  	if (is_hugepd(__hugepd(pmd_val(pmdval)))) {
> -		page = follow_huge_pd(vma, address,
> -				      __hugepd(pmd_val(pmdval)), flags,
> -				      PMD_SHIFT);
> +		page = follow_huge_pd(ctx->vma, ctx->address,
> +				      __hugepd(pmd_val(pmdval)),
> +				      ctx->flags, PGDIR_SHIFT);

Shoot, that should have been PMD_SHIFT.

I'll let this current set sit a little longer before considering v2.
