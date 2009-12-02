Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F28B6600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:11:56 -0500 (EST)
Date: Wed, 2 Dec 2009 14:11:50 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 06/24] HWPOISON: abort on failed unmap
Message-ID: <20091202131150.GE18989@one.firstfloor.org>
References: <20091202031231.735876003@intel.com> <20091202043044.293905787@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202043044.293905787@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

>  	 * Now take care of user space mappings.
> +	 * Abort on fail: __remove_from_page_cache() assumes unmapped page.
>  	 */
> -	hwpoison_user_mappings(p, pfn, trapno);
> +	if (hwpoison_user_mappings(p, pfn, trapno) != SWAP_SUCCESS) {
> +		res = -EBUSY;
> +		goto out;

It would be good to print something in this case.

Did you actually see it during testing?

Or maybe loop forever in the unmapper.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
