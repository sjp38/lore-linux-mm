Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id F0A2D6B0003
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 16:12:50 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id j6-v6so4393478pll.10
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:12:50 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id n10si2306386pgc.681.2018.02.26.13.12.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 13:12:49 -0800 (PST)
Subject: Re: [PATCH v12 1/3] mm, powerpc, x86: define VM_PKEY_BITx bits if
 CONFIG_ARCH_HAS_PKEYS is enabled
References: <1519257138-23797-1-git-send-email-linuxram@us.ibm.com>
 <1519257138-23797-2-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a5481355-9630-7f63-15ce-2b12d1520979@intel.com>
Date: Mon, 26 Feb 2018 13:12:46 -0800
MIME-Version: 1.0
In-Reply-To: <1519257138-23797-2-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

On 02/21/2018 03:52 PM, Ram Pai wrote:
> VM_PKEY_BITx are defined only if CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
> is enabled. Powerpc also needs these bits. Hence lets define the
> VM_PKEY_BITx bits for any architecture that enables
> CONFIG_ARCH_HAS_PKEYS.

Your fixed version looks fine to me.

Reviewed-by: Dave Hansen <dave.hansen@intel.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
