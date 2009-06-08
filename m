Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5B06B005A
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 10:43:23 -0400 (EDT)
Date: Mon, 8 Jun 2009 18:03:24 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86, UV: Fix nacros for multiple coherency domains
Message-ID: <20090608160324.GA4355@elte.hu>
References: <20090608154405.GA16395@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090608154405.GA16395@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Jack Steiner <steiner@sgi.com>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


* Jack Steiner <steiner@sgi.com> wrote:

> Fix bug in the SGI UV macros that support systems with multiple 
> coherency domains.  The macros used for referencing global MMR 
> (chipset registers) are failing to correctly "or" the NASID (node 
> identifier) bits that reside above M+N. These high bits are 
> supplied automatically by the chipset for memory accesses coming 
> from the processor socket. However, the bits must be present for 
> references to the special global MMR space used to map chipset 
> registers. (See uv_hub.h for more details ...)
> 
> The bug results in references to invalid/incorrect nodes.
> 
> Signed-off-by: Jack Steiner <steiner@sgi.com>
> 
> ---
>  arch/x86/include/asm/uv/uv_hub.h   |    6 ++++--
>  arch/x86/kernel/apic/x2apic_uv_x.c |   15 +++++++++------
>  2 files changed, 13 insertions(+), 8 deletions(-)

Applied, thanks Jack. Note - this has missed .30 but i marked it for 
.30.1 backporting, because it obviously only affects UV code.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
