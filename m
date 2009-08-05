Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 08BEC6B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 10:10:01 -0400 (EDT)
Date: Wed, 5 Aug 2009 16:10:01 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [11/19] HWPOISON: Refactor truncate to allow direct
	truncating of page v2
Message-ID: <20090805141001.GJ11385@basil.fritz.box>
References: <200908051136.682859934@firstfloor.org> <20090805093638.D3754B15D8@basil.firstfloor.org> <20090805102008.GB17190@wotan.suse.de> <20090805134607.GH11385@basil.fritz.box> <20090805140145.GB28563@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805140145.GB28563@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>

> I haven't brought up the caller at this point, but IIRC you had
> the page locked and mapping confirmed at this point anyway so
> it would never be an error for your code.
> 
> Probably it would be nice to just force callers to verify the page.
> Normally IMO it is much nicer and clearer to do it at the time the
> page gets locked, unless there is good reason otherwise.

Ok. I think I'll just keep it as it is for now.

The only reason I added the error code was to make truncate_inode_page
fit into .error_remove_page, but then latter I did another wrapper
so it could be removed again. But it won't hurt to have it either.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
