Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A6D346B000E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 09:44:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id z83so2810723wmc.2
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 06:44:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e43si557618edd.37.2018.04.12.06.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 06:44:53 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3CDeGDl003867
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 09:44:51 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ha79hc2yk-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 09:44:51 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 12 Apr 2018 14:44:46 +0100
Subject: Re: [PATCH v9 21/24] perf tools: Add support for the SPF perf event
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-22-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803261443560.255554@chino.kir.corp.google.com>
 <20180327034936.GO13724@tassilo.jf.intel.com>
 <alpine.DEB.2.21.1804092346090.225864@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 12 Apr 2018 15:44:36 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1804092346090.225864@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <de5f854b-fd39-21e1-1ce9-1c5c2d292eb8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andi Kleen <ak@linux.intel.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 10/04/2018 08:47, David Rientjes wrote:
> On Mon, 26 Mar 2018, Andi Kleen wrote:
> 
>>> Aside: should there be a new spec_flt field for struct task_struct that 
>>> complements maj_flt and min_flt and be exported through /proc/pid/stat?
>>
>> No. task_struct is already too bloated. If you need per process tracking 
>> you can always get it through trace points.
>>
> 
> Hi Andi,
> 
> We have
> 
> 	count_vm_event(PGFAULT);
> 	count_memcg_event_mm(vma->vm_mm, PGFAULT);
> 
> in handle_mm_fault() but not counterpart for spf.  I think it would be 
> helpful to be able to determine how much faulting can be done 
> speculatively if there is no per-process tracking without tracing.

That sounds to be a good idea, I will create a separate patch a dedicated
speculative_pgfault counter as PGFAULT is.

Thanks,
Laurent.
