Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9BB6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 10:44:40 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v12-v6so10740314wmc.1
        for <linux-mm@kvack.org>; Tue, 29 May 2018 07:44:40 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id e50-v6si3779015eda.35.2018.05.29.07.44.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 07:44:38 -0700 (PDT)
Date: Tue, 29 May 2018 16:44:38 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH v3 3/3] x86/mm: add TLB purge to free pmd/pte page
 interfaces
Message-ID: <20180529144438.GM18595@8bytes.org>
References: <20180516233207.1580-1-toshi.kani@hpe.com>
 <20180516233207.1580-4-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180516233207.1580-4-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, tglx@linutronix.de, Toshi Kani <toshi.kani@hpe.com>
Cc: mhocko@suse.com, akpm@linux-foundation.org, hpa@zytor.com, cpandya@codeaurora.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Wed, May 16, 2018 at 05:32:07PM -0600, Toshi Kani wrote:
>  	pmd = (pmd_t *)pud_page_vaddr(*pud);
> +	pmd_sv = (pmd_t *)__get_free_page(GFP_KERNEL);
> +	if (!pmd_sv)
> +		return 0;

So your code still needs to allocate a full page where a simple
list_head on the stack would do the same job.

Ingo, Thomas, can you please just revert the original broken patch for
now until there is proper fix?

Thanks,

	Joerg
