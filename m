Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1C6E6B02FD
	for <linux-mm@kvack.org>; Sun,  9 Jul 2017 23:07:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so21172590wrb.6
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 20:07:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e11si7368962wre.37.2017.07.09.20.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jul 2017 20:07:40 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6A33Yql135422
	for <linux-mm@kvack.org>; Sun, 9 Jul 2017 23:07:39 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bjv03ty6p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 09 Jul 2017 23:07:39 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 10 Jul 2017 13:07:36 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6A37YcV19595396
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:07:34 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6A37Ps5004383
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:07:26 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: [RFC v5 34/38] procfs: display the protection-key number
 associated with a vma
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-35-git-send-email-linuxram@us.ibm.com>
Date: Mon, 10 Jul 2017 08:37:28 +0530
MIME-Version: 1.0
In-Reply-To: <1499289735-14220-35-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <1162ac6c-5e34-8a6c-fed2-6683d261352c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On 07/06/2017 02:52 AM, Ram Pai wrote:
> Display the pkey number associated with the vma in smaps of a task.
> The key will be seen as below:
> 
> ProtectionKey: 0
> 
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/powerpc/kernel/setup_64.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
> index f35ff9d..ebc82b3 100644
> --- a/arch/powerpc/kernel/setup_64.c
> +++ b/arch/powerpc/kernel/setup_64.c
> @@ -37,6 +37,7 @@
>  #include <linux/memblock.h>
>  #include <linux/memory.h>
>  #include <linux/nmi.h>
> +#include <linux/pkeys.h>
>  
>  #include <asm/io.h>
>  #include <asm/kdump.h>
> @@ -745,3 +746,10 @@ static int __init disable_hardlockup_detector(void)
>  }
>  early_initcall(disable_hardlockup_detector);
>  #endif
> +
> +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS

Why not for X86 protection keys ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
