Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 825026B0640
	for <linux-mm@kvack.org>; Thu, 10 May 2018 16:24:49 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id x30-v6so2609333qtm.20
        for <linux-mm@kvack.org>; Thu, 10 May 2018 13:24:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d6-v6si1558753qtk.224.2018.05.10.13.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 13:24:48 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4AKOBI0017445
	for <linux-mm@kvack.org>; Thu, 10 May 2018 16:24:47 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hvu0n5efk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 May 2018 16:24:47 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 10 May 2018 21:24:45 +0100
Date: Thu, 10 May 2018 13:24:36 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH 9/8] powerpc/pkeys: Drop private VM_PKEY definitions
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180508145948.9492-9-mpe@ellerman.id.au>
 <20180510135422.6585-1-mpe@ellerman.id.au>
MIME-Version: 1.0
In-Reply-To: <20180510135422.6585-1-mpe@ellerman.id.au>
Message-Id: <20180510202435.GB6257@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com


Agree. Was going to send that the moment the other patches
landed upstream. Glad I dont have to do it :-)

Reviewed-by: Ram Pai <linuxram@us.ibm.com>



On Thu, May 10, 2018 at 11:54:22PM +1000, Michael Ellerman wrote:
> Now that we've updated the generic headers to support 5 PKEY bits for
> powerpc we don't need our own #defines in arch code.
> 
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> ---
>  arch/powerpc/include/asm/pkeys.h | 15 ---------------
>  1 file changed, 15 deletions(-)
> 
> One additional patch to finish cleaning things up.
> 
> I've added this to my branch.
> 
> cheers
> 
> diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
> index 18ef59a9886d..5ba80cffb505 100644
> --- a/arch/powerpc/include/asm/pkeys.h
> +++ b/arch/powerpc/include/asm/pkeys.h
> @@ -15,21 +15,6 @@ DECLARE_STATIC_KEY_TRUE(pkey_disabled);
>  extern int pkeys_total; /* total pkeys as per device tree */
>  extern u32 initial_allocation_mask; /* bits set for reserved keys */
> 
> -/*
> - * Define these here temporarily so we're not dependent on patching linux/mm.h.
> - * Once it's updated we can drop these.
> - */
> -#ifndef VM_PKEY_BIT0
> -# define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
> -# define VM_PKEY_BIT0	VM_HIGH_ARCH_0
> -# define VM_PKEY_BIT1	VM_HIGH_ARCH_1
> -# define VM_PKEY_BIT2	VM_HIGH_ARCH_2
> -# define VM_PKEY_BIT3	VM_HIGH_ARCH_3
> -# define VM_PKEY_BIT4	VM_HIGH_ARCH_4
> -#elif !defined(VM_PKEY_BIT4)
> -# define VM_PKEY_BIT4	VM_HIGH_ARCH_4
> -#endif
> -
>  #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | \
>  			    VM_PKEY_BIT3 | VM_PKEY_BIT4)
> 
> -- 
> 2.14.1

-- 
Ram Pai
