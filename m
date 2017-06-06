Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0A8B6B0314
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 17:36:08 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id a30so14607727otd.2
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 14:36:08 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i56si7719322otc.196.2017.06.06.14.36.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 14:36:08 -0700 (PDT)
Received: from mail-vk0-f50.google.com (mail-vk0-f50.google.com [209.85.213.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 71A5A23A06
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 21:36:07 +0000 (UTC)
Received: by mail-vk0-f50.google.com with SMTP id g66so28449654vki.1
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 14:36:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a5226797-87b7-ee00-e81d-793b7dc92a80@oracle.com>
References: <cover.1496701658.git.luto@kernel.org> <1de32b6e3ff026886713adab887a9454548d8374.1496701658.git.luto@kernel.org>
 <a5226797-87b7-ee00-e81d-793b7dc92a80@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 6 Jun 2017 14:35:46 -0700
Message-ID: <CALCETrVYnoE5orTr9DpcXxKWYhWAVhkL3sP3_Rdd-8L0-H0tjg@mail.gmail.com>
Subject: Re: [RFC 10/11] x86/mm: Enable CR4.PCIDE on supported systems
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Juergen Gross <jgross@suse.com>

On Tue, Jun 6, 2017 at 2:31 PM, Boris Ostrovsky
<boris.ostrovsky@oracle.com> wrote:
>
>> --- a/arch/x86/xen/setup.c
>> +++ b/arch/x86/xen/setup.c
>> @@ -1037,6 +1037,12 @@ void __init xen_arch_setup(void)
>>       }
>>  #endif
>>
>> +     /*
>> +      * Xen would need some work to support PCID: CR3 handling as well
>> +      * as xen_flush_tlb_others() would need updating.
>> +      */
>> +     setup_clear_cpu_cap(X86_FEATURE_PCID);
>
>
> Capabilities for PV guests are typically set in xen_init_capabilities() now.

Do I need this just for PV or for all Xen guests?  Do the
hardware-assisted guests still use paravirt flushes?  Does the
hypervisor either support PCID or correctly clear the PCID CPUID bit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
