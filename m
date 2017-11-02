Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E6D5F6B0038
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 15:38:06 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v78so603949pgb.18
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 12:38:06 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w6si4122162pgb.291.2017.11.02.12.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 12:38:05 -0700 (PDT)
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171102190106.GC22263@arm.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <816a3491-3c2c-ec0a-810f-b593c25968f2@linux.intel.com>
Date: Thu, 2 Nov 2017 12:38:05 -0700
MIME-Version: 1.0
In-Reply-To: <20171102190106.GC22263@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On 11/02/2017 12:01 PM, Will Deacon wrote:
> On Tue, Oct 31, 2017 at 03:31:46PM -0700, Dave Hansen wrote:
>> KAISER makes it harder to defeat KASLR, but makes syscalls and
>> interrupts slower.  These patches are based on work from a team at
>> Graz University of Technology posted here[1].  The major addition is
>> support for Intel PCIDs which builds on top of Andy Lutomorski's PCID
>> work merged for 4.14.  PCIDs make KAISER's overhead very reasonable
>> for a wide variety of use cases.
> I just wanted to say that I've got a version of this up and running for
> arm64. I'm still ironing out a few small details, but I hope to post it
> after the merge window. We always use ASIDs, and the perf impact looks
> like it aligns roughly with your findings for a PCID-enabled x86 system.

Welcome to the party!

I don't know if you've found anything different, but there been woefully
little code that's really cross-architecture.  The kernel task
stack-mapping stuff _was_, but it's going away.  The per-cpu-user-mapped
section stuff might be common, I guess.

Is there any other common infrastructure that we can or should be sharing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
