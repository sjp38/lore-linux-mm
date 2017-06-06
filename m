Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE426B0314
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 17:54:39 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id h4so184006563oib.5
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 14:54:39 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t64si11174805ota.69.2017.06.06.14.54.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 14:54:38 -0700 (PDT)
Received: from mail-vk0-f51.google.com (mail-vk0-f51.google.com [209.85.213.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E5ADA239EF
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 21:54:37 +0000 (UTC)
Received: by mail-vk0-f51.google.com with SMTP id p62so51969072vkp.0
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 14:54:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <dcaaa527-7875-9f7b-4b55-f1c439899607@oracle.com>
References: <cover.1496701658.git.luto@kernel.org> <1de32b6e3ff026886713adab887a9454548d8374.1496701658.git.luto@kernel.org>
 <a5226797-87b7-ee00-e81d-793b7dc92a80@oracle.com> <CALCETrVYnoE5orTr9DpcXxKWYhWAVhkL3sP3_Rdd-8L0-H0tjg@mail.gmail.com>
 <dcaaa527-7875-9f7b-4b55-f1c439899607@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 6 Jun 2017 14:54:16 -0700
Message-ID: <CALCETrU4XAs6mkWJT5qaq050EOOGQBzK_VVVf2yT0ucCpr4N7A@mail.gmail.com>
Subject: Re: [RFC 10/11] x86/mm: Enable CR4.PCIDE on supported systems
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Juergen Gross <jgross@suse.com>

On Tue, Jun 6, 2017 at 2:48 PM, Boris Ostrovsky
<boris.ostrovsky@oracle.com> wrote:
> On 06/06/2017 05:35 PM, Andy Lutomirski wrote:
>> On Tue, Jun 6, 2017 at 2:31 PM, Boris Ostrovsky
>> <boris.ostrovsky@oracle.com> wrote:
>>>> --- a/arch/x86/xen/setup.c
>>>> +++ b/arch/x86/xen/setup.c
>>>> @@ -1037,6 +1037,12 @@ void __init xen_arch_setup(void)
>>>>       }
>>>>  #endif
>>>>
>>>> +     /*
>>>> +      * Xen would need some work to support PCID: CR3 handling as well
>>>> +      * as xen_flush_tlb_others() would need updating.
>>>> +      */
>>>> +     setup_clear_cpu_cap(X86_FEATURE_PCID);
>>>
>>> Capabilities for PV guests are typically set in xen_init_capabilities() now.
>> Do I need this just for PV or for all Xen guests?  Do the
>> hardware-assisted guests still use paravirt flushes?  Does the
>> hypervisor either support PCID or correctly clear the PCID CPUID bit?
>
>
> For HVM guests Xen will DTRT for CPUID so dealing with PV should be
> sufficient (and xen_arch_setup() is called on PV only anyway)
>
> As far as flushes are concerned for now it's PV only although I believe
> Juergen is thinking about doing this on HVM too.

OK.  I'll move the code to xen_init_capabilities() for the next version.

>
> -boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
