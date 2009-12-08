Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4592A60021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 06:26:27 -0500 (EST)
Date: Tue, 8 Dec 2009 12:26:23 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: hwpoison madvise code
Message-ID: <20091208112623.GX18989@one.firstfloor.org>
References: <20091208112412.GA6038@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091208112412.GA6038@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, fengguang.wu@intel.com, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 08, 2009 at 12:24:12PM +0100, Nick Piggin wrote:
> Hi,
> 
> Seems like the madvise hwpoison code is ugly and buggy, not to
> put too fine a point on it :)
> 
> Ugly: it should have just followed the same pattern as the other
> transient advices.

That wouldn't work.

> Buggy: it doesn't take mmap_sem. If it followed the pattern, it
> wouldn't have had this bug.

get_user_pages takes mmap_sem if needed.

If you think that is broken please describe the failure scenario
in detail.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
