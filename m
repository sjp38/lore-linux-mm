Date: Wed, 7 Mar 2007 10:35:18 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070307093518.GB8424@elte.hu>
References: <20070221023656.6306.246.sendpatchset@linux.site> <20070221023735.6306.83373.sendpatchset@linux.site> <20070306225101.f393632c.akpm@linux-foundation.org> <20070307070853.GB15877@wotan.suse.de> <20070307081948.GA9563@wotan.suse.de> <20070307082755.GA25733@elte.hu> <20070307085944.GA17433@wotan.suse.de> <20070307092252.GA6499@elte.hu> <20070307093208.GK18774@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070307093208.GK18774@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Irwin <bill.irwin@oracle.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

* Bill Irwin <bill.irwin@oracle.com> wrote:

> * Nick Piggin <npiggin@suse.de> wrote:
> >> After these patches, I don't think there is too much burden. The main 
> >> thing left really is just the objrmap stuff, but that is just handled 
> >> with a minimal 'dumb' algorithm that doesn't cost much.
> 
> On Wed, Mar 07, 2007 at 10:22:52AM +0100, Ingo Molnar wrote:
> > ok. What do you think about the sys_remap_file_pages_prot() thing that 
> > Paolo has done in a nicely split up form - does that complicate things 
> > in any fundamental way? That is what is useful to UML.
> 
> Oracle would love it. You don't want to know how far back I've been 
> asked to backport that.

ok, cool! Then the first step would be for you to talk to Paolo and to 
pick up the patches, review them, nurse it in -mm, etc. Suffering in 
silence is just a pointless act of masochism, not an efficient 
upstream-merge tactic ;-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
