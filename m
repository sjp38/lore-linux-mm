Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E8EA06B0055
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:43:32 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f10so1404210qtc.0
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 03:43:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z131si3684374qka.265.2018.03.28.03.43.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 03:43:32 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2SAh8PY131230
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:43:31 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h09hp80dh-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:43:30 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 28 Mar 2018 11:43:27 +0100
Subject: Re: [PATCH v9 06/24] mm: make pte_unmap_same compatible with SPF
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-7-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803271417510.31115@chino.kir.corp.google.com>
 <fd9eedf4-b885-d8f5-2daa-4cc450e72427@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803280318440.69353@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 28 Mar 2018 12:43:15 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803280318440.69353@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <c144821a-6a78-f395-4480-ea929c7f08f6@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org



On 28/03/2018 12:20, David Rientjes wrote:
> On Wed, 28 Mar 2018, Laurent Dufour wrote:
> 
>>>> @@ -2913,7 +2921,8 @@ int do_swap_page(struct vm_fault *vmf)
>>>>  	int exclusive = 0;
>>>>  	int ret = 0;
>>>
>>> Initialization is now unneeded.
>>
>> I'm sorry, what "initialization" are you talking about here ?
>>
> 
> The initialization of the ret variable.
> 
> @@ -2913,7 +2921,8 @@ int do_swap_page(struct vm_fault *vmf)
>  	int exclusive = 0;
>  	int ret = 0;
> 
> -	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
> +	ret = pte_unmap_same(vmf);
> +	if (ret)
>  		goto out;
> 
>  	entry = pte_to_swp_entry(vmf->orig_pte);
> 
> "ret" is immediately set to the return value of pte_unmap_same(), so there 
> is no need to initialize it to 0.

Sorry, I missed that. I'll remove this initialization.

Thanks,
Laurent.
