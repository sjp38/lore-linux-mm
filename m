Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 887BB6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 15:01:05 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s144so553469oih.5
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 12:01:05 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a53si2309233otj.509.2017.11.02.12.01.04
        for <linux-mm@kvack.org>;
        Thu, 02 Nov 2017 12:01:04 -0700 (PDT)
Date: Thu, 2 Nov 2017 19:01:07 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Message-ID: <20171102190106.GC22263@arm.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

Hi Dave,

[+linux-arm-kernel]

On Tue, Oct 31, 2017 at 03:31:46PM -0700, Dave Hansen wrote:
> KAISER makes it harder to defeat KASLR, but makes syscalls and
> interrupts slower.  These patches are based on work from a team at
> Graz University of Technology posted here[1].  The major addition is
> support for Intel PCIDs which builds on top of Andy Lutomorski's PCID
> work merged for 4.14.  PCIDs make KAISER's overhead very reasonable
> for a wide variety of use cases.

I just wanted to say that I've got a version of this up and running for
arm64. I'm still ironing out a few small details, but I hope to post it
after the merge window. We always use ASIDs, and the perf impact looks
like it aligns roughly with your findings for a PCID-enabled x86 system.

Cheers,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
