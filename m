Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 31E9D6B0027
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 15:38:10 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 69-v6so8208934plc.18
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:38:10 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id u59-v6si4619415plb.177.2018.03.23.12.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 12:38:09 -0700 (PDT)
Subject: Re: [PATCH 05/11] x86/mm: do not auto-massage page protections
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <20180323174454.CD00F614@viggo.jf.intel.com>
 <224464E0-1D3A-4ED8-88E0-A8E84C4265FC@vmware.com>
 <ed72b04d-de86-113e-ab45-e1577e5c4226@linux.intel.com>
 <D608FB5E-5254-4233-98DC-605EDEF24E9E@vmware.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <c911e7f5-32ba-fed7-c464-7e91584b0e55@linux.intel.com>
Date: Fri, 23 Mar 2018 12:38:07 -0700
MIME-Version: 1.0
In-Reply-To: <D608FB5E-5254-4233-98DC-605EDEF24E9E@vmware.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "keescook@google.com" <keescook@google.com>, "hughd@google.com" <hughd@google.com>, "jgross@suse.com" <jgross@suse.com>, "x86@kernel.org" <x86@kernel.org>

On 03/23/2018 12:34 PM, Nadav Amit wrote:
>>>> +	/* mmdebug.h can not be included here because of dependencies */
>>>> +#ifdef CONFIG_DEBUG_VM
>>>> +	WARN_ONCE(pgprot_val(pgprot) != massaged_val,
>>>> +		  "attempted to set unsupported pgprot: %016lx "
>>>> +		  "bits: %016lx supported: %016lx\n",
>>>> +		  pgprot_val(pgprot),
>>>> +		  pgprot_val(pgprot) ^ massaged_val,
>>>> +		  __supported_pte_mask);
>>>> +#endif
>>> Why not to use VM_WARN_ON_ONCE() and avoid the ifdef?
>> I wanted a message.  VM_WARN_ON_ONCE() doesn't let you give a message.
> Right (my bad). But VM_WARN_ONCE() lets you.

I put a comment in up there about this ^^.  #including mmdebug.h caused
dependency problems, so I basically just reimplemented it using
WARN_ONCE() and an #ifdef.
