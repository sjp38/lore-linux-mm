Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C5C0E6B0106
	for <linux-mm@kvack.org>; Wed, 13 May 2009 10:08:10 -0400 (EDT)
Date: Wed, 13 May 2009 16:13:35 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu
Message-ID: <20090513141335.GS19296@one.firstfloor.org>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com> <87r5ytl0nn.fsf@basil.nowhere.org> <2f11576a0905130418w1782f85j12cb938e92d256ff@mail.gmail.com> <20090513113817.GO19296@one.firstfloor.org> <2f11576a0905130458x2e56e952ga47216da42b30906@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f11576a0905130458x2e56e952ga47216da42b30906@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Minchan@firstfloor.org
List-ID: <linux-mm.kvack.org>

> 1. this featuren don't depend CONFIG_MMU. that's bogus.

Without CONFIG_MMU everything is unevictable, so you don't need
to special case unevictable pages.  Or are you saying it should
use this code always?

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
