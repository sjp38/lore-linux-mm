Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2976810B5
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:14:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s70so7037521pfs.5
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 11:14:32 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id k1si436445pld.351.2017.07.11.11.14.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 11:14:31 -0700 (PDT)
Subject: Re: [RFC v5 34/38] procfs: display the protection-key number
 associated with a vma
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-35-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <8b0827c9-9fc9-c2d5-d1a5-52d9eef8965e@intel.com>
Date: Tue, 11 Jul 2017 11:13:56 -0700
MIME-Version: 1.0
In-Reply-To: <1499289735-14220-35-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On 07/05/2017 02:22 PM, Ram Pai wrote:
> +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> +void arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
> +{
> +	seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> +}
> +#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */

This seems like kinda silly unnecessary duplication.  Could we just put
this in the fs/proc/ code and #ifdef it on ARCH_HAS_PKEYS?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
