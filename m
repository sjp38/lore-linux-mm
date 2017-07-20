Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8249C6B037C
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:57:56 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id z1so23966865pgs.10
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 22:57:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r1si1116558pfe.649.2017.07.19.22.57.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 22:57:55 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6K5s66S063072
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:57:55 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2btjhmgd6a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:57:54 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 20 Jul 2017 15:57:52 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6K5uaGx24313890
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 15:56:36 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6K5uaq8026316
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 15:56:36 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC v6 05/62] powerpc: capture the PTE format changes in the dump pte report
In-Reply-To: <1500177424-13695-6-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-6-git-send-email-linuxram@us.ibm.com>
Date: Thu, 20 Jul 2017 11:26:28 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <877ez3r6r7.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Ram Pai <linuxram@us.ibm.com> writes:

> The H_PAGE_F_SECOND,H_PAGE_F_GIX are not in the 64K main-PTE.
> capture these changes in the dump pte report.
>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/powerpc/mm/dump_linuxpagetables.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/arch/powerpc/mm/dump_linuxpagetables.c b/arch/powerpc/mm/dump_linuxpagetables.c
> index 44fe483..5627edd 100644
> --- a/arch/powerpc/mm/dump_linuxpagetables.c
> +++ b/arch/powerpc/mm/dump_linuxpagetables.c
> @@ -213,7 +213,7 @@ struct flag_info {
>  		.val	= H_PAGE_4K_PFN,
>  		.set	= "4K_pfn",
>  	}, {
> -#endif
> +#else /* CONFIG_PPC_64K_PAGES */
>  		.mask	= H_PAGE_F_GIX,
>  		.val	= H_PAGE_F_GIX,
>  		.set	= "f_gix",
> @@ -224,6 +224,7 @@ struct flag_info {
>  		.val	= H_PAGE_F_SECOND,
>  		.set	= "f_second",
>  	}, {
> +#endif /* CONFIG_PPC_64K_PAGES */
>  #endif
>  		.mask	= _PAGE_SPECIAL,
>  		.val	= _PAGE_SPECIAL,
> -- 
> 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
