Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3566B0062
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 10:16:39 -0400 (EDT)
Date: Wed, 5 Aug 2009 16:16:42 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [11/19] HWPOISON: Refactor truncate to allow direct truncating of page v2
Message-ID: <20090805141642.GB23992@wotan.suse.de>
References: <200908051136.682859934@firstfloor.org> <20090805093638.D3754B15D8@basil.firstfloor.org> <20090805102008.GB17190@wotan.suse.de> <20090805134607.GH11385@basil.fritz.box> <20090805140145.GB28563@wotan.suse.de> <20090805141001.GJ11385@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805141001.GJ11385@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 04:10:01PM +0200, Andi Kleen wrote:
> > I haven't brought up the caller at this point, but IIRC you had
> > the page locked and mapping confirmed at this point anyway so
> > it would never be an error for your code.
> > 
> > Probably it would be nice to just force callers to verify the page.
> > Normally IMO it is much nicer and clearer to do it at the time the
> > page gets locked, unless there is good reason otherwise.
> 
> Ok. I think I'll just keep it as it is for now.
> 
> The only reason I added the error code was to make truncate_inode_page
> fit into .error_remove_page, but then latter I did another wrapper
> so it could be removed again. But it won't hurt to have it either.

OK, it's more of a cleanup/nit.

One question I had for the others (Andrew? other mm guys?) what is the
feelings of merging this feature? Leaving aside exact implementation
and just considering the high level design and cost/benefit. Last time
there were some people objecting, so I wonder the situation now? So
does anybody need more convincing? :)

Also I will just cc linux-arch. It would be interesting to know whether
powerpc, ia64, or s390 or others would be interested to use this feature?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
