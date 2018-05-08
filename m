Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8236B02B1
	for <linux-mm@kvack.org>; Tue,  8 May 2018 12:45:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f11-v6so2099333plj.23
        for <linux-mm@kvack.org>; Tue, 08 May 2018 09:45:07 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 9-v6si18226226ple.63.2018.05.08.09.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 09:45:05 -0700 (PDT)
Subject: Re: [PATCH 4/8] mm/pkeys, powerpc, x86: Provide an empty vma_pkey()
 in linux/pkeys.h
References: <20180508145948.9492-1-mpe@ellerman.id.au>
 <20180508145948.9492-5-mpe@ellerman.id.au>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <1a37801a-fde1-53a3-0082-735834d1e9a4@intel.com>
Date: Tue, 8 May 2018 09:45:02 -0700
MIME-Version: 1.0
In-Reply-To: <20180508145948.9492-5-mpe@ellerman.id.au>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, linuxram@us.ibm.com
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On 05/08/2018 07:59 AM, Michael Ellerman wrote:
> Consolidate the pkey handling by providing a common empty definition
> of vma_pkey() in pkeys.h when CONFIG_ARCH_HAS_PKEYS=n.
> 
> This also removes another entanglement of pkeys.h and
> asm/mmu_context.h.

Looks fine to me.  Thanks for consolidating these.

Reviewed-by: Dave Hansen <dave.hansen@intel.com>
