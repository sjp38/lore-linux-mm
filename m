Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5986B004F
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 07:16:32 -0400 (EDT)
Date: Mon, 1 Jun 2009 13:16:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v4
Message-ID: <20090601111641.GA5018@wotan.suse.de>
References: <200905291135.124267638@firstfloor.org> <20090529213539.4FACC1D0296@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090529213539.4FACC1D0296@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: hugh@veritas.com, riel@redhat.com, chris.mason@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, May 29, 2009 at 11:35:39PM +0200, Andi Kleen wrote:
> +	mapping = page_mapping(p);
> +	if (!PageDirty(p) && !PageWriteback(p) &&
> +	    !PageAnon(p) && !PageSwapBacked(p) &&
> +	    mapping && mapping_cap_account_dirty(mapping)) {

Haven't had another good look at this yet, but if you hold the
page locked, and have done a wait_on_page_writeback, then
PageWriteback == true is a kernel bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
