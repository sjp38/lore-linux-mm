Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDEB6B0324
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 14:10:00 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g125-v6so16275770ita.0
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 11:10:00 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 205-v6si2407501itf.102.2018.07.09.11.09.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 11:09:59 -0700 (PDT)
Date: Mon, 9 Jul 2018 14:09:49 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv4 07/18] x86/mm: Introduce variables to store number,
 shift and mask of KeyIDs
Message-ID: <20180709180949.GH6873@char.US.ORACLE.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-8-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180626142245.82850-8-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
> index 4b101dd6e52f..4ebee899c363 100644
> --- a/arch/x86/mm/Makefile
> +++ b/arch/x86/mm/Makefile
> @@ -53,3 +53,5 @@ obj-$(CONFIG_PAGE_TABLE_ISOLATION)		+= pti.o
>  obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
>  obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
>  obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
> +
> +obj-$(CONFIG_X86_INTEL_MKTME)	+= mktme.o

Any particular reason to have x86 in the CONFIG?

> diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
> new file mode 100644
> index 000000000000..467f1b26c737
> --- /dev/null
> +++ b/arch/x86/mm/mktme.c
> @@ -0,0 +1,5 @@
> +#include <asm/mktme.h>
> +
> +phys_addr_t mktme_keyid_mask;
> +int mktme_nr_keyids;
> +int mktme_keyid_shift;
> -- 
> 2.18.0
> 
