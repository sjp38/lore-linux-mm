Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 764A56B004F
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 08:46:42 -0400 (EDT)
Date: Mon, 1 Jun 2009 20:46:58 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in the VM v4
Message-ID: <20090601124657.GA30813@localhost>
References: <200905291135.124267638@firstfloor.org> <20090529213539.4FACC1D0296@basil.firstfloor.org> <20090601111641.GA5018@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090601111641.GA5018@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 01, 2009 at 07:16:41PM +0800, Nick Piggin wrote:
> On Fri, May 29, 2009 at 11:35:39PM +0200, Andi Kleen wrote:
> > +	mapping = page_mapping(p);
> > +	if (!PageDirty(p) && !PageWriteback(p) &&
> > +	    !PageAnon(p) && !PageSwapBacked(p) &&
> > +	    mapping && mapping_cap_account_dirty(mapping)) {
> 
> Haven't had another good look at this yet, but if you hold the
> page locked, and have done a wait_on_page_writeback, then
> PageWriteback == true is a kernel bug.

Right, we can eliminate the PageWriteback() test when there is a
wait_on_page_writeback().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
