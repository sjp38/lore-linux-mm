Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE886B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 07:48:45 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.14.3/8.13.8) with ESMTP id n76BmWIE105686
	for <linux-mm@kvack.org>; Thu, 6 Aug 2009 11:48:32 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n76BmWjc2437156
	for <linux-mm@kvack.org>; Thu, 6 Aug 2009 13:48:32 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n76BmWPL017950
	for <linux-mm@kvack.org>; Thu, 6 Aug 2009 13:48:32 +0200
Date: Thu, 6 Aug 2009 13:48:30 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] [11/19] HWPOISON: Refactor truncate to allow direct
 truncating of page v2
Message-ID: <20090806134830.4f3931d2@skybase>
In-Reply-To: <20090805141642.GB23992@wotan.suse.de>
References: <200908051136.682859934@firstfloor.org>
	<20090805093638.D3754B15D8@basil.firstfloor.org>
	<20090805102008.GB17190@wotan.suse.de>
	<20090805134607.GH11385@basil.fritz.box>
	<20090805140145.GB28563@wotan.suse.de>
	<20090805141001.GJ11385@basil.fritz.box>
	<20090805141642.GB23992@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 5 Aug 2009 16:16:42 +0200
Nick Piggin <npiggin@suse.de> wrote:

> On Wed, Aug 05, 2009 at 04:10:01PM +0200, Andi Kleen wrote:
> > > I haven't brought up the caller at this point, but IIRC you had
> > > the page locked and mapping confirmed at this point anyway so
> > > it would never be an error for your code.
> > > 
> > > Probably it would be nice to just force callers to verify the page.
> > > Normally IMO it is much nicer and clearer to do it at the time the
> > > page gets locked, unless there is good reason otherwise.
> > 
> > Ok. I think I'll just keep it as it is for now.
> > 
> > The only reason I added the error code was to make truncate_inode_page
> > fit into .error_remove_page, but then latter I did another wrapper
> > so it could be removed again. But it won't hurt to have it either.
> 
> OK, it's more of a cleanup/nit.
> 
> One question I had for the others (Andrew? other mm guys?) what is the
> feelings of merging this feature? Leaving aside exact implementation
> and just considering the high level design and cost/benefit. Last time
> there were some people objecting, so I wonder the situation now? So
> does anybody need more convincing? :)
> 
> Also I will just cc linux-arch. It would be interesting to know whether
> powerpc, ia64, or s390 or others would be interested to use this feature?

This is not relevant for s390, as current machines do transparent memory
sparing if a memory module goes bad. Really old machines reported bad
memory to the OS by means of a machine check (storage error uncorrected
and storage error corrected). I have never seen this happen, the level
below the OS deals with these errors for us.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
