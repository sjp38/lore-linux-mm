Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 138196B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 12:37:42 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id v195so6168862qka.10
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 09:37:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u1si149489qkh.42.2018.01.15.09.37.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jan 2018 09:37:40 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0FHUfLR012861
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 12:37:39 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fgx91fkkh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 12:37:39 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 15 Jan 2018 17:37:36 -0000
Subject: Re: [PATCH v6 01/24] x86/mm: Define CONFIG_SPF
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1515777968-867-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1801121955150.2371@nanos>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 15 Jan 2018 18:37:25 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1801121955150.2371@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <753d7b28-3d7e-0c01-0386-8dad161f88ea@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hi Thomas,

Thanks for reviewing this series.

On 12/01/2018 19:57, Thomas Gleixner wrote:
> On Fri, 12 Jan 2018, Laurent Dufour wrote:
> 
>> Introduce CONFIG_SPF which turns on the Speculative Page Fault handler when
>> building for 64bits with SMP.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  arch/x86/Kconfig | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index a317d5594b6a..d74353b85aaf 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -2882,6 +2882,10 @@ config X86_DMA_REMAP
>>  config HAVE_GENERIC_GUP
>>  	def_bool y
>>  
>> +config SPF
>> +	def_bool y
>> +	depends on X86_64 && SMP
> 
> Can you please put that into a generic place as
> 
>     config SPF
>     	   bool
> 
> and let the architectures select it.

I'll change that to let the architectures (x86 and ppc64 currently)
selecting it, but the definition will remain in the arch/xxx/Kconfig file
since it depends on the architecture support in the page fault handler.

> Also SPF could be bit more elaborate and self explaining for the causual
> reader. 3 letter acronyms are reserved for non existing agencies.

That's true 3 letter acronyms are already reserved...
I'll change it to CONFIG_SPECULATIVE_PAGE_FAULT as suggested by Matthew Wilcox.

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
