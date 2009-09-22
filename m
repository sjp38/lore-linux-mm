Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C58E56B006A
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 19:50:46 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [BUG 2.6.30+] e100 sometimes causes oops during resume
Date: Wed, 23 Sep 2009 01:51:36 +0200
References: <20090915120538.GA26806@bizet.domek.prywatny> <200909180027.37387.rjw@sisk.pl> <20090922233531.GA3198@bizet.domek.prywatny>
In-Reply-To: <20090922233531.GA3198@bizet.domek.prywatny>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200909230151.36678.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Cc: david.graham@intel.com, "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 23 September 2009, Karol Lewandowski wrote:
> On Fri, Sep 18, 2009 at 12:27:37AM +0200, Rafael J. Wysocki wrote:
> > On Thursday 17 September 2009, Graham, David wrote:
> > > Rafael J. Wysocki wrote:
> > > > I guess the driver releases its DMA buffer during suspend and attempts to
> > > > allocate it back on resume, which is not really smart (if that really is the
> > > > case).
> 
> > > Yes, we free a 70KB block (0x80 by 0x230 bytes) on suspend and 
> > > reallocate on resume, and so that's an Order 5 request. It looks 
> > > symmetric, and hasn't changed for years. I don't think we are leaking 
> > > memory, which points back to that the memory is too fragmented to 
> > > satisfy the request.
> > > 
> > > I also concur that Rafael's commit 6905b1f1 shouldn't change the logic 
> > > in the driver for systems with e100 (like yours Karol) that could 
> > > already sleep, and I don't see anything else in the driver that looks to 
> > > be relevant. I'm expecting that your test result without commit 6905b1f1 
> > > will still show the problem.
> > > 
> > > So I wonder if this new issue may be triggered by some other change in 
> > > the memory subsystem ?
> 
> > I think so.  There have been reports about order 2 allocations failing for
> > 2.6.31, so it looks like newer kernels are more likely to expose such problems.
> > 
> > Adding linux-mm to the CC list.
> 
> I've hit this bug 2 times since my last email.  Is there anything I
> could do?
> 
> Maybe I should revert following commits (chosen somewhat randomly)?
> 
> 1. 49255c619fbd482d704289b5eb2795f8e3b7ff2e
> 
> 2. dd5d241ea955006122d76af88af87de73fec25b4 - alters changes made by
> commit above
> 
> Any ideas?

You can try that IMO.

Best,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
