Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 64DA66B004A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 08:14:21 -0400 (EDT)
Date: Fri, 1 Jul 2011 14:14:08 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] mm: Move definition of MIN_MEMORY_BLOCK_SIZE to a
 header
Message-ID: <20110701121408.GC28008@elte.hu>
References: <1308013070.2874.784.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308013070.2874.784.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>


* Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> The macro MIN_MEMORY_BLOCK_SIZE is currently defined twice in two .c
> files, and I need it in a third one to fix a powerpc bug, so let's
> first move it into a header
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> 
> Ingo, Thomas: Who needs to ack the x86 bit ? I'd like to send that
> to Linus asap with the powerpc fix.

Acked-by: Ingo Molnar <mingo@elte.hu>

(btw., you can consider obvious cleanups as being implicitly acked by 
me and don't need to block fixes on me.)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
