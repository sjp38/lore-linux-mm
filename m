Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6AF28028D
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 13:41:28 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z184so9930206pgd.0
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 10:41:28 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f9si9914344pfc.10.2017.11.10.10.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 10:41:27 -0800 (PST)
Subject: Re: [PATCH 20/30] x86, mm: remove hard-coded ASID limit checks
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194724.C0167D83@viggo.jf.intel.com>
 <20171110122030.5zyplbb3tnwpa2vu@hirez.programming.kicks-ass.net>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <52465ada-a7e9-ccb3-e946-5a7c8a0476c5@linux.intel.com>
Date: Fri, 10 Nov 2017 10:41:26 -0800
MIME-Version: 1.0
In-Reply-To: <20171110122030.5zyplbb3tnwpa2vu@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/10/2017 04:20 AM, Peter Zijlstra wrote:
> On Wed, Nov 08, 2017 at 11:47:24AM -0800, Dave Hansen wrote:
>> +#define CR3_HW_ASID_BITS 12
>> +#define NR_AVAIL_ASIDS ((1<<CR3_AVAIL_ASID_BITS) - 1)
> That evaluates to 4095
> 
>> -		VM_WARN_ON_ONCE(asid > 4094);
>> +		VM_WARN_ON_ONCE(asid > NR_AVAIL_ASIDS);
> Not the same number

I think this got fixed up in the next patch (the check becomes a >=),
but I'll fix this to make it more clean and fix the intermediate breakage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
