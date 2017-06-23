Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50B3B6B0292
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 09:36:24 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m54so18820374qtb.9
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 06:36:24 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r1si3863645qkc.287.2017.06.23.06.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 06:36:23 -0700 (PDT)
Subject: Re: [PATCH v3 10/11] x86/mm: Enable CR4.PCIDE on supported systems
References: <cover.1498022414.git.luto@kernel.org>
 <57c1d18b1c11f9bc9a3bcf8bdee38033415e1a13.1498022414.git.luto@kernel.org>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <f982991b-6c1c-2343-7df8-6fd5753cc410@oracle.com>
Date: Fri, 23 Jun 2017 09:35:44 -0400
MIME-Version: 1.0
In-Reply-To: <57c1d18b1c11f9bc9a3bcf8bdee38033415e1a13.1498022414.git.luto@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Juergen Gross <jgross@suse.com>


> diff --git a/arch/x86/xen/enlighten_pv.c b/arch/x86/xen/enlighten_pv.c
> index f33eef4ebd12..a136aac543c3 100644
> --- a/arch/x86/xen/enlighten_pv.c
> +++ b/arch/x86/xen/enlighten_pv.c
> @@ -295,6 +295,12 @@ static void __init xen_init_capabilities(void)
>   	setup_clear_cpu_cap(X86_FEATURE_ACC);
>   	setup_clear_cpu_cap(X86_FEATURE_X2APIC);
>   
> +	/*
> +	 * Xen PV would need some work to support PCID: CR3 handling as well
> +	 * as xen_flush_tlb_others() would need updating.
> +	 */
> +	setup_clear_cpu_cap(X86_FEATURE_PCID);
> +
>   	if (!xen_initial_domain())
>   		setup_clear_cpu_cap(X86_FEATURE_ACPI);
>   


Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
