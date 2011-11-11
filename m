Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6F98A6B0072
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 23:31:35 -0500 (EST)
Message-ID: <1320985863.21206.40.camel@pasglop>
Subject: Re: mm: convert vma->vm_flags to 64bit
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 11 Nov 2011 15:31:03 +1100
In-Reply-To: <alpine.LSU.2.00.1111101723500.1239@sister.anvils>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com>
	 <CAPQyPG7RrpV8DBV_Qcgr2at_r25_ngjy_84J2FqzRPGfA3PGDA@mail.gmail.com>
	 <4EBC085D.3060107@jp.fujitsu.com> <1320959579.21206.24.camel@pasglop>
	 <alpine.LSU.2.00.1111101723500.1239@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, nai.xia@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, dave@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, lethal@linux-sh.org, linux@arm.linux.org.uk

On Thu, 2011-11-10 at 18:09 -0800, Hugh Dickins wrote:
> It was in this mail below, when Andrew sent Linus the patch, and Linus
> opposed my "argument" in support: that wasn't on lkml or linux-mm,
> but I don't see that its privacy needs protecting.
> 
> KOSAKI-san then sent instead a patch to correct some ints to longs,
> which Linus did put in: but changing them to a new "vm_flags_t".
> 
> He was, I think, hoping that one of us would change all the other uses
> of unsigned long vm_flags to vm_flags_t; but in fact none of us has
> stepped up yet - yeah, we're still sulking that we didn't get our
> shiny new 64-bit vm_flags ;)
> 
> I think Linus is not opposed to PowerPC and others defining a 64-bit
> vm_flags_t if you need it, but wants not to bloat the x86_32 vma.
> 
> I'm still wary of the contortions we go to in constraining flags,
> and feel that the 32-bit case holds back the 64-bit, which would
> not itself be bloated at all.
> 
> The subject is likely to come up again, more pressingly, with page
> flags.

Right, tho the good first step is to convert everything to vm_flags_t so
we can easily switch if we want to, even on a per-arch basis...

Oh well, now all we need is a volunteer :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
