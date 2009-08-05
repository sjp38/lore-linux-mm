Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 49AF26B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 10:41:15 -0400 (EDT)
Date: Wed, 5 Aug 2009 16:41:12 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [11/19] HWPOISON: Refactor truncate to allow direct
	truncating of page v2
Message-ID: <20090805144112.GM11385@basil.fritz.box>
References: <200908051136.682859934@firstfloor.org> <20090805093638.D3754B15D8@basil.firstfloor.org> <20090805102008.GB17190@wotan.suse.de> <20090805134607.GH11385@basil.fritz.box> <20090805140145.GB28563@wotan.suse.de> <20090805141001.GJ11385@basil.fritz.box> <20090805141642.GB23992@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805141642.GB23992@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> One question I had for the others (Andrew? other mm guys?) what is the
> feelings of merging this feature? Leaving aside exact implementation
> and just considering the high level design and cost/benefit. Last time
> there were some people objecting, so I wonder the situation now? So
> does anybody need more convincing? :)

The main objection last time was that it was a bit too late in the 
release schedule.

I can't remember anyone really questioning the basic feature itself.

> Also I will just cc linux-arch. It would be interesting to know whether
> powerpc, ia64, or s390 or others would be interested to use this feature?

ia64 is interested (but no code so far) I talked to DaveM and he seems to be 
interested for sparc too.  I would expect other server architectures to 
eventually use it as they get around to writing the necessary architecture 
specific glue.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
