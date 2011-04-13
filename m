Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AE293900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 03:30:40 -0400 (EDT)
Date: Wed, 13 Apr 2011 08:29:35 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mm: convert vma->vm_flags to 64bit
Message-ID: <20110413072935.GK7806@n2100.arm.linux.org.uk>
References: <BANLkTinLdWB+ON=TY=KHyzsrC8gC5bXg7Q@mail.gmail.com> <1302646024.28876.52.camel@pasglop> <20110413091301.41E1.A69D9226@jp.fujitsu.com> <20110413064432.GA4098@p183> <1302678049.28876.77.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1302678049.28876.77.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>

On Wed, Apr 13, 2011 at 05:00:49PM +1000, Benjamin Herrenschmidt wrote:
> On Wed, 2011-04-13 at 09:44 +0300, Alexey Dobriyan wrote:
> > > Yes, I take Hugh's version because vm_flags_t is ugly to me. And
> > arch 
> > > dependent variable size is problematic.
> > 
> > Who said it should have arch-dependent size? 
> 
> Right, it shouldn't. My original patch did that to avoid thinking about
> archs that manipulated it from asm such as ARM but that wasn't the right
> thing to do. But that doesn't invalidate having a type.

No, we don't manipulate it.  We only test for VM_EXEC in it in asm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
