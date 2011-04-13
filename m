Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 07AF9900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 03:01:21 -0400 (EDT)
Subject: Re: mm: convert vma->vm_flags to 64bit
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20110413064432.GA4098@p183>
References: <BANLkTinLdWB+ON=TY=KHyzsrC8gC5bXg7Q@mail.gmail.com>
	 <1302646024.28876.52.camel@pasglop>
	 <20110413091301.41E1.A69D9226@jp.fujitsu.com>  <20110413064432.GA4098@p183>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 13 Apr 2011 17:00:49 +1000
Message-ID: <1302678049.28876.77.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

On Wed, 2011-04-13 at 09:44 +0300, Alexey Dobriyan wrote:
> > Yes, I take Hugh's version because vm_flags_t is ugly to me. And
> arch 
> > dependent variable size is problematic.
> 
> Who said it should have arch-dependent size? 

Right, it shouldn't. My original patch did that to avoid thinking about
archs that manipulated it from asm such as ARM but that wasn't the right
thing to do. But that doesn't invalidate having a type.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
