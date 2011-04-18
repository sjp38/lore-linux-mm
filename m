Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD5E900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 21:46:12 -0400 (EDT)
Subject: Re: mm: convert vma->vm_flags to 64bit
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LSU.2.00.1104171649350.21405@sister.anvils>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com>
	 <alpine.LSU.2.00.1104171649350.21405@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 18 Apr 2011 11:45:39 +1000
Message-ID: <1303091139.28876.152.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

On Sun, 2011-04-17 at 17:26 -0700, Hugh Dickins wrote:
> I am surprised that
> #define VM_EXEC         0x00000004ULL
> does not cause trouble for arch/arm/kernel/asm-offsets.c,
> but you tried cross-building it which I never did.

It would probably cause trouble for a big endian ARM no ? In that case
it should offset the load by 4.

> Does your later addition of __nocast on vm_flags not make trouble
> for the unsigned long casts in arch/arm/include/asm/cacheflush.h?
> (And if it does not, then just what does __nocast do?)
> 
> Thanks for seeing this through, 

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
