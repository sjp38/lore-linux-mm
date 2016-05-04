Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7006B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 17:21:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b203so131537908pfb.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 14:21:22 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id s202si6695300pfs.76.2016.05.04.14.21.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 14:21:21 -0700 (PDT)
Subject: Re: [RFC 1/5] powerpc: Rename context.vdso_base to context.vdso
References: <20151202121918.GA4523@arm.com>
 <1461856737-17071-1-git-send-email-cov@codeaurora.org>
 <1461856737-17071-2-git-send-email-cov@codeaurora.org>
 <5726A7D5.7030305@gmail.com>
From: Christopher Covington <cov@codeaurora.org>
Message-ID: <572A67CE.4010109@codeaurora.org>
Date: Wed, 4 May 2016 17:21:18 -0400
MIME-Version: 1.0
In-Reply-To: <5726A7D5.7030305@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, criu@openvz.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Will Deacon <Will.Deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Hi Balbir,

On 05/01/2016 09:05 PM, Balbir Singh wrote:
> On 29/04/16 01:18, Christopher Covington wrote:
>> In order to share remap and unmap support for the VDSO with other
>> architectures without duplicating the code, we need a common name and type
>> for the address of the VDSO. An informal survey of the architectures
>> indicates unsigned long vdso is popular. Change the variable name in
>> powerpc from mm->context.vdso_base to simply mm->context.vdso.
> 
> Could you please provide additional details on why the remap/unmap operations are required?

The goal is to make checkpointing and restoring processes work on
several different architectures and ABIs, in the face of Address Space
Layout Randomization (ASLR) and other factors that might change the VDSO
virtual address from one exec() to the next.

Here's the patch adding PowerPC support:

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=83d3f0e90c6c8f833e3da91917c243a916fda69e

> This patch does rename, but should it abstract via a function acesss
> to vmap field using arch_* operations? Not sure

I'm sorry, but I don't understand this question. Are you saying ARM,
Power etc. need VDSO unmap and remap log that behave differently? So far
I've found the differences to be stylistic rather than really affecting
generated code behavior.

Thanks,
Christopher Covington

-- 
Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
