Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes
	nonlinear)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070307101728.GA5555@wotan.suse.de>
References: <20070221023656.6306.246.sendpatchset@linux.site>
	 <20070221023735.6306.83373.sendpatchset@linux.site>
	 <20070306225101.f393632c.akpm@linux-foundation.org>
	 <1173261949.9349.37.camel@localhost.localdomain>
	 <20070307101728.GA5555@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 07 Mar 2007 11:46:08 +0100
Message-Id: <1173264368.9349.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-03-07 at 11:17 +0100, Nick Piggin wrote:
> On Wed, Mar 07, 2007 at 11:05:48AM +0100, Benjamin Herrenschmidt wrote:
> > 
> > > > NOPAGE_REFAULT is removed. This should be implemented with ->fault, and
> > > > no users have hit mainline yet.
> > > 
> > > Did benh agree with that?
> > 
> > I won't use NOPAGE_REFAULT, I use NOPFN_REFAULT and that has hit
> > mainline. I will switch to ->fault when I have time to adapt the code,
> > in the meantime, NOPFN_REFAULT should stay.
> 
> I think I removed not only NOFPN_REFAULT, but also nopfn itself, *and*
> adapted the code for you ;) it is in patch 5/6, sent a while ago. 

Ok, I need to look. I've been travelling, having meeting etc... for the
last couple of weeks and I'm taking a week off next week :-)

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
