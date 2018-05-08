Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCC06B02AD
	for <linux-mm@kvack.org>; Tue,  8 May 2018 12:27:29 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y6-v6so21975038wrm.10
        for <linux-mm@kvack.org>; Tue, 08 May 2018 09:27:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t24-v6si7970963edm.246.2018.05.08.09.27.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 09:27:27 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w48GOwPP000620
	for <linux-mm@kvack.org>; Tue, 8 May 2018 12:27:25 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2huc1h40xn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 May 2018 12:27:25 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 8 May 2018 17:27:23 +0100
Date: Tue, 8 May 2018 09:27:15 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH 4/8] mm/pkeys, powerpc, x86: Provide an empty vma_pkey()
 in linux/pkeys.h
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180508145948.9492-1-mpe@ellerman.id.au>
 <20180508145948.9492-5-mpe@ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180508145948.9492-5-mpe@ellerman.id.au>
Message-Id: <20180508162715.GB5474@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com

On Wed, May 09, 2018 at 12:59:44AM +1000, Michael Ellerman wrote:
> Consolidate the pkey handling by providing a common empty definition
> of vma_pkey() in pkeys.h when CONFIG_ARCH_HAS_PKEYS=n.
> 
> This also removes another entanglement of pkeys.h and
> asm/mmu_context.h.
>

Reviewed-by: Ram Pai <linuxram@us.ibm.com>


> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> ---
>  arch/powerpc/include/asm/mmu_context.h | 5 -----
>  arch/x86/include/asm/mmu_context.h     | 5 -----
>  include/linux/pkeys.h                  | 5 +++++
>  3 files changed, 5 insertions(+), 10 deletions(-)

RP
