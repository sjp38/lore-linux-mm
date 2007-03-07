Date: Wed, 7 Mar 2007 11:17:28 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070307101728.GA5555@wotan.suse.de>
References: <20070221023656.6306.246.sendpatchset@linux.site> <20070221023735.6306.83373.sendpatchset@linux.site> <20070306225101.f393632c.akpm@linux-foundation.org> <1173261949.9349.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1173261949.9349.37.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 07, 2007 at 11:05:48AM +0100, Benjamin Herrenschmidt wrote:
> 
> > > NOPAGE_REFAULT is removed. This should be implemented with ->fault, and
> > > no users have hit mainline yet.
> > 
> > Did benh agree with that?
> 
> I won't use NOPAGE_REFAULT, I use NOPFN_REFAULT and that has hit
> mainline. I will switch to ->fault when I have time to adapt the code,
> in the meantime, NOPFN_REFAULT should stay.

I think I removed not only NOFPN_REFAULT, but also nopfn itself, *and*
adapted the code for you ;) it is in patch 5/6, sent a while ago. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
