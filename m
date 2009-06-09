Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D984D6B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 06:15:26 -0400 (EDT)
Date: Tue, 9 Jun 2009 12:48:25 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in  the VM v3
Message-ID: <20090609104825.GJ14820@wotan.suse.de>
References: <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org> <20090528145021.GA5503@localhost> <ab418ea90906032325m302afbb6w6fa68f6b57f53e49@mail.gmail.com> <20090607160225.GA24315@localhost> <ab418ea90906080406y34981329y27d360624aa22f7c@mail.gmail.com> <20090608123133.GA7944@localhost> <ab418ea90906080746m6d1d59d8m395ab76585575db1@mail.gmail.com> <20090609064855.GB5490@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609064855.GB5490@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Nai Xia <nai.xia@gmail.com>, Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 02:48:55PM +0800, Wu Fengguang wrote:
> On Mon, Jun 08, 2009 at 10:46:53PM +0800, Nai Xia wrote:
> > I meant PG_writeback stops writers to index---->struct page mapping.
> 
> It's protected by the radix tree RCU locks. Period.
> 
> If you are referring to the reverse mapping: page->mapping is procted
> by PG_lock. No one should make assumption that it won't change under
> page writeback.

Well... I think probably PG_writeback should be enough. Phrased another
way: I think it is a very bad idea to truncate PG_writeback pages out of
pagecache. Does anything actually do that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
