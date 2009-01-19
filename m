Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0EEA76B0044
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 18:32:43 -0500 (EST)
Date: Tue, 20 Jan 2009 00:32:27 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86_64: remove kernel_physical_mapping_init() from
	init section
Message-ID: <20090119233227.GA310@elte.hu>
References: <20090119214641.GB7476@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090119214641.GB7476@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yhlu.kernel@gmail.com, lcm@us.ibm.com, x86@kernel.org
List-ID: <linux-mm.kvack.org>


* Gary Hade <garyhade@us.ibm.com> wrote:

> kernel_physical_mapping_init() is called during memory hotplug so it 
> does not belong in the init section.
> 
> If the kernel is built with CONFIG_DEBUG_SECTION_MISMATCH=y on the make 
> command line, arch/x86/mm/init_64.c is compiled with the 
> -fno-inline-functions-called-once gcc option defeating inlining of 
> kernel_physical_mapping_init() within init_memory_mapping(). When 
> kernel_physical_mapping_init() is not inlined it is placed in the 
> .init.text section according to the __init in it's current declaration.  
> A later call to kernel_physical_mapping_init() during a memory hotplug 
> operation encounters an int3 trap because the .init.text section memory 
> has been freed.  This patch eliminates the crash caused by the int3 trap 
> by moving the non-inlined kernel_physical_mapping_init() from .init.text 
> to .meminit.text.
> 
> Signed-off-by: Gary Hade <garyhade@us.ibm.com>

applied to tip/x86/urgent, thanks Gary!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
