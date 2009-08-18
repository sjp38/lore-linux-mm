Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 61AAB6B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 11:38:21 -0400 (EDT)
Date: Tue, 18 Aug 2009 17:38:15 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] replace various uses of num_physpages by totalram_pages
Message-ID: <20090818153815.GA11913@elte.hu>
References: <4A8AE6280200007800010539@vpn.id2.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A8AE6280200007800010539@vpn.id2.novell.com>
Sender: owner-linux-mm@kvack.org
To: Jan Beulich <JBeulich@novell.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>


* Jan Beulich <JBeulich@novell.com> wrote:

> Sizing of memory allocations shouldn't depend on the number of 
> physical pages found in a system, as that generally includes 
> (perhaps a huge amount of) non-RAM pages. The amount of what 
> actually is usable as storage should instead be used as a basis 
> here.
> 
> Some of the calculations (i.e. those not intending to use high 
> memory) should likely even use (totalram_pages - 
> totalhigh_pages).
> 
> Signed-off-by: Jan Beulich <jbeulich@novell.com>
> Acked-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> ---
>  arch/x86/kernel/microcode_core.c  |    4 ++--

Acked-by: Ingo Molnar <mingo@elte.hu>

Just curious: how did you find this bug? Did you find this by 
experiencing problems on a system with a lot of declared non-RAM 
memory?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
