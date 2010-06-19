Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DF8DC6B0071
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 15:52:45 -0400 (EDT)
Date: Sat, 19 Jun 2010 21:52:42 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [31/31] HWPOISON: Add a madvise() injector for soft
 page offlining
Message-ID: <20100619195242.GS18946@basil.fritz.box>
References: <200912081016.198135742@firstfloor.org>
 <20091208211647.9B032B151F@basil.firstfloor.org>
 <AANLkTimBhQAYn7BDXd1ykSN90v0ClWybIe2Pe1qv_6vA@mail.gmail.com>
 <20100619132055.GK18946@basil.fritz.box>
 <AANLkTin-lj5ZgtcvJhWcNiMuWSCQ39N8mqe_2fm8DDVR@mail.gmail.com>
 <20100619133000.GL18946@basil.fritz.box>
 <AANLkTiloIXtCwBeBvP32hLBBvxCWrZMMwWTZwSj475wi@mail.gmail.com>
 <20100619140933.GM18946@basil.fritz.box>
 <AANLkTilF6m5YKMiDGaTNuoW6LxiA44oss3HyvkavwrOK@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTilF6m5YKMiDGaTNuoW6LxiA44oss3HyvkavwrOK@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> .TP
> .BR MADV_SOFT_OFFLINE " (Since Linux 2.6.33)
> Soft offline the pages in the range specified by
> .I addr
> and
> .IR length .
> This memory of each page in the specified range is copied to a new page,

Actually there are some cases where it's also dropped if it's cached page.

Perhaps better would be something more fuzzy like

"the contents are preserved"

> and the original page is offlined
> (i.e., no longer used, and taken out of normal memory management).

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
