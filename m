Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes
	nonlinear)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070306225101.f393632c.akpm@linux-foundation.org>
References: <20070221023656.6306.246.sendpatchset@linux.site>
	 <20070221023735.6306.83373.sendpatchset@linux.site>
	 <20070306225101.f393632c.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 07 Mar 2007 11:05:48 +0100
Message-Id: <1173261949.9349.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> > NOPAGE_REFAULT is removed. This should be implemented with ->fault, and
> > no users have hit mainline yet.
> 
> Did benh agree with that?

I won't use NOPAGE_REFAULT, I use NOPFN_REFAULT and that has hit
mainline. I will switch to ->fault when I have time to adapt the code,
in the meantime, NOPFN_REFAULT should stay.

Note that one thing we really want with the new ->fault (though I
haven't looked at the patches lately to see if it's available) is to be
able to differenciate faults coming from userspace from faults coming
from the kernel. The major difference is that the former can be
re-executed to handle signals, the later can't. Thus waiting in the
fault handler can be made interruptible in the former case, not in the
later case.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
