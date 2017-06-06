Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86C956B0314
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 17:31:46 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y201so44856543qka.6
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 14:31:46 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z66si11755306qkb.213.2017.06.06.14.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 14:31:45 -0700 (PDT)
Subject: Re: [RFC 10/11] x86/mm: Enable CR4.PCIDE on supported systems
References: <cover.1496701658.git.luto@kernel.org>
 <1de32b6e3ff026886713adab887a9454548d8374.1496701658.git.luto@kernel.org>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <a5226797-87b7-ee00-e81d-793b7dc92a80@oracle.com>
Date: Tue, 6 Jun 2017 17:31:30 -0400
MIME-Version: 1.0
In-Reply-To: <1de32b6e3ff026886713adab887a9454548d8374.1496701658.git.luto@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Juergen Gross <jgross@suse.com>


> --- a/arch/x86/xen/setup.c
> +++ b/arch/x86/xen/setup.c
> @@ -1037,6 +1037,12 @@ void __init xen_arch_setup(void)
>  	}
>  #endif
>  
> +	/*
> +	 * Xen would need some work to support PCID: CR3 handling as well
> +	 * as xen_flush_tlb_others() would need updating.
> +	 */
> +	setup_clear_cpu_cap(X86_FEATURE_PCID);


Capabilities for PV guests are typically set in xen_init_capabilities() now.


-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
