Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B7AF4600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:13:32 -0500 (EST)
Date: Wed, 2 Dec 2009 14:13:30 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 10/24] HWPOISON: remove the free buddy page handler
Message-ID: <20091202131330.GF18989@one.firstfloor.org>
References: <20091202031231.735876003@intel.com> <20091202043044.878843398@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202043044.878843398@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 11:12:41AM +0800, Wu Fengguang wrote:
> The buddy page has already be handled in the very beginning.
> So remove redundant code.

I think I prefer the table to be complete, even if some of the 
cases might not happen currently. A BUG() would be reasonable though.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
