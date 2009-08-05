Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 908EE6B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 10:44:02 -0400 (EDT)
Date: Wed, 5 Aug 2009 16:44:02 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [11/19] HWPOISON: Refactor truncate to allow direct truncating of page v2
Message-ID: <20090805144402.GD23992@wotan.suse.de>
References: <200908051136.682859934@firstfloor.org> <20090805093638.D3754B15D8@basil.firstfloor.org> <20090805102008.GB17190@wotan.suse.de> <20090805134607.GH11385@basil.fritz.box> <20090805140145.GB28563@wotan.suse.de> <20090805141001.GJ11385@basil.fritz.box> <20090805141642.GB23992@wotan.suse.de> <20090805144112.GM11385@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805144112.GM11385@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 04:41:12PM +0200, Andi Kleen wrote:
> > One question I had for the others (Andrew? other mm guys?) what is the
> > feelings of merging this feature? Leaving aside exact implementation
> > and just considering the high level design and cost/benefit. Last time
> > there were some people objecting, so I wonder the situation now? So
> > does anybody need more convincing? :)
> 
> The main objection last time was that it was a bit too late in the 
> release schedule.
> 
> I can't remember anyone really questioning the basic feature itself.

I can't exactly remember. Maybe it was in a thread with Alan and/or
Arjan ;) I don't think the feature itself was questioned as much as
cost/benefit. Maybe I was wrong...

I just want to see everyone is happy with the basic idea ;)


> > Also I will just cc linux-arch. It would be interesting to know whether
> > powerpc, ia64, or s390 or others would be interested to use this feature?
> 
> ia64 is interested (but no code so far) I talked to DaveM and he seems to be 
> interested for sparc too.  I would expect other server architectures to 
> eventually use it as they get around to writing the necessary architecture 
> specific glue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
