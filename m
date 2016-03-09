Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id C6B556B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 11:03:12 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id n5so5798914pfn.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 08:03:12 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ks7si13300029pab.129.2016.03.09.08.03.11
        for <linux-mm@kvack.org>;
        Wed, 09 Mar 2016 08:03:11 -0800 (PST)
Date: Wed, 9 Mar 2016 16:03:26 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: arch/ia64/kernel/entry.S:621: Error: Operand 2 of `adds' should
 be a 14-bit integer (-8192-8191)
Message-ID: <20160309160325.GH28496@arm.com>
References: <201603062105.9tHMvN5r%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603062105.9tHMvN5r%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sun, Mar 06, 2016 at 09:47:10PM +0800, kbuild test robot wrote:
> FYI, the error/warning still remains.

[...]

>    arch/ia64/kernel/entry.S: Assembler messages:
> >> arch/ia64/kernel/entry.S:621: Error: Operand 2 of `adds' should be a 14-bit integer (-8192-8191)
>    arch/ia64/kernel/entry.S:728: Error: Operand 2 of `adds' should be a 14-bit integer (-8192-8191)
>    arch/ia64/kernel/entry.S:859: Error: Operand 2 of `adds' should be a 14-bit integer (-8192-8191)
> --
>    arch/ia64/kernel/fsys.S: Assembler messages:
> >> arch/ia64/kernel/fsys.S:67: Error: Operand 3 of `add' should be a general register r0-r3
>    arch/ia64/kernel/fsys.S:97: Error: Operand 3 of `add' should be a general register r0-r3
>    arch/ia64/kernel/fsys.S:193: Error: Operand 3 of `add' should be a general register r0-r3
>    arch/ia64/kernel/fsys.S:336: Error: Operand 3 of `add' should be a general register r0-r3
>    arch/ia64/kernel/fsys.S:338: Error: Operand 3 of `add' should be a general register r0-r3
> --
>    arch/ia64/kernel/ivt.S: Assembler messages:
> >> arch/ia64/kernel/ivt.S:759: Error: Operand 3 of `add' should be a general register r0-r3

Yeah :( I reported this on linux-arch a while back:

http://lkml.kernel.org/r/20160127150031.GI2390@arm.com

but didn't get any replies (I cc'd the maintainers).

Tell you what; I'll repost the fix I had there (basically disabling
LATENCYTOP for ia64) as a separate patch and see how it goes.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
