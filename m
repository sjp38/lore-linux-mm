Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2786B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 16:49:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x17so2407618pfn.10
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 13:49:07 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0067.outbound.protection.outlook.com. [104.47.36.67])
        by mx.google.com with ESMTPS id c5-v6si1049042plo.461.2018.04.09.13.49.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 13:49:06 -0700 (PDT)
Subject: Re: [PATCH 00/11] [v5] Use global pages with PTI
References: <20180406205501.24A1A4E7@viggo.jf.intel.com>
 <c96373d0-c16a-4463-147c-8624ad90af61@amd.com>
 <b9802f89-93b3-b535-742c-f84e9f5be832@linux.intel.com>
 <1b45ffd1-99bb-4ac1-fb65-0de3e42c1c0a@amd.com>
 <f87b6f47-2416-4c12-55dd-5f0cb86f1464@linux.intel.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <12a224de-b298-94ad-9a09-79ac67fac80b@amd.com>
Date: Mon, 9 Apr 2018 15:48:54 -0500
MIME-Version: 1.0
In-Reply-To: <f87b6f47-2416-4c12-55dd-5f0cb86f1464@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com

On 4/9/2018 2:50 PM, Dave Hansen wrote:
> On 04/09/2018 11:59 AM, Tom Lendacky wrote:
>> On 4/9/2018 1:17 PM, Dave Hansen wrote:
>>> On 04/09/2018 11:04 AM, Tom Lendacky wrote:
>>>> On 4/6/2018 3:55 PM, Dave Hansen wrote:
>>>>> Changes from v4
>>>>>  * Fix compile error reported by Tom Lendacky
>>>> This built with CONFIG_RANDOMIZE_BASE=y, but failed to boot successfully.
>>>> I think you're missing the initialization of __default_kernel_pte_mask in
>>>> kaslr.c.
>>>
>>> This should be simple to fix (just add a -1 instead of 0), but let me
>>> double-check and actually boot the fix.
>>
>> Yup, added an "= ~0" and everything is good.
> 
> I'm testing at this commit in the tip tree:
> 
> 0564258... x86/pti: Leave kernel text global for !PCID
> 
> It seems to boot OK with RANDOMIZE_BASE=y for both PCID and non-PCID
> configuration.  Could you send along your .config so I can try to reproduce?
> 

Sure, I'll send it to you directly as an attachment.

Thanks,
Tom
