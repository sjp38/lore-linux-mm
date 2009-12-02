Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4D303600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 07:47:35 -0500 (EST)
Date: Wed, 2 Dec 2009 13:47:30 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 14/24] HWPOISON: return 0 if page is assured to be isolated
Message-ID: <20091202124730.GB18989@one.firstfloor.org>
References: <20091202031231.735876003@intel.com> <20091202043045.394560341@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202043045.394560341@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 11:12:45AM +0800, Wu Fengguang wrote:
> Introduce hpc.page_isolated to record if page is assured to be
> isolated, ie. it won't be accessed in normal kernel code paths
> and therefore won't trigger another MCE event.
> 
> __memory_failure() will now return 0 to indicate that page is
> really isolated.  Note that the original used action result
> RECOVERED is not a reliable criterion.
> 
> Note that we now don't bother to risk returning 0 for the
> rare unpoison/truncated cases.

That's the only user of the new hwpoison_control structure right?
I think I prefer for that single bit to extend the return values
and keep the arguments around. structures are not nice to read.

I'll change the code.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
