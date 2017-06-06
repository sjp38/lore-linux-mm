Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 927016B0314
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 17:49:09 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id s33so68773325qtg.1
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 14:49:09 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g53si20295902qtc.275.2017.06.06.14.49.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 14:49:08 -0700 (PDT)
Subject: Re: [RFC 10/11] x86/mm: Enable CR4.PCIDE on supported systems
References: <cover.1496701658.git.luto@kernel.org>
 <1de32b6e3ff026886713adab887a9454548d8374.1496701658.git.luto@kernel.org>
 <a5226797-87b7-ee00-e81d-793b7dc92a80@oracle.com>
 <CALCETrVYnoE5orTr9DpcXxKWYhWAVhkL3sP3_Rdd-8L0-H0tjg@mail.gmail.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <dcaaa527-7875-9f7b-4b55-f1c439899607@oracle.com>
Date: Tue, 6 Jun 2017 17:48:52 -0400
MIME-Version: 1.0
In-Reply-To: <CALCETrVYnoE5orTr9DpcXxKWYhWAVhkL3sP3_Rdd-8L0-H0tjg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Juergen Gross <jgross@suse.com>

On 06/06/2017 05:35 PM, Andy Lutomirski wrote:
> On Tue, Jun 6, 2017 at 2:31 PM, Boris Ostrovsky
> <boris.ostrovsky@oracle.com> wrote:
>>> --- a/arch/x86/xen/setup.c
>>> +++ b/arch/x86/xen/setup.c
>>> @@ -1037,6 +1037,12 @@ void __init xen_arch_setup(void)
>>>       }
>>>  #endif
>>>
>>> +     /*
>>> +      * Xen would need some work to support PCID: CR3 handling as well
>>> +      * as xen_flush_tlb_others() would need updating.
>>> +      */
>>> +     setup_clear_cpu_cap(X86_FEATURE_PCID);
>>
>> Capabilities for PV guests are typically set in xen_init_capabilities() now.
> Do I need this just for PV or for all Xen guests?  Do the
> hardware-assisted guests still use paravirt flushes?  Does the
> hypervisor either support PCID or correctly clear the PCID CPUID bit?


For HVM guests Xen will DTRT for CPUID so dealing with PV should be
sufficient (and xen_arch_setup() is called on PV only anyway)

As far as flushes are concerned for now it's PV only although I believe
Juergen is thinking about doing this on HVM too.

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
