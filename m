Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1066B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 11:59:59 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so64741579pdb.1
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 08:59:58 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id vx6si4048325pab.220.2015.04.30.08.59.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 08:59:58 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 30 Apr 2015 21:29:54 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id B55A43940069
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 21:29:50 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3UFxnwf19923196
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 21:29:49 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3UFxnvk026551
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 21:29:49 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/3] mm/thp: Use pmdp_splitting_flush_notify to clear pmd on splitting
In-Reply-To: <20150430133035.GF15874@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1430382341-8316-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1430382341-8316-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150430133035.GF15874@node.dhcp.inet.fi>
Date: Thu, 30 Apr 2015 21:29:48 +0530
Message-ID: <87iocd38uj.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

>> @@ -184,3 +185,13 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
>>  }
>>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>>  #endif
>> +
>> +#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH_NOTIFY
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
>> +				 unsigned long address, pmd_t *pmdp)
>> +{
>> +	pmdp_clear_flush_notify(vma, address, pmdp);
>> +}
>> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>> +#endif
>
> I think it worth inlining. Let's put it to <asm-generic/pgtable.h>
>
> It probably worth combining with collapse counterpart in the same patch.
>

I tried that first, But that pulls in mmu_notifier.h and huge_mm.h
headers and other build failures

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
