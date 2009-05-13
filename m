Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D76506B00E8
	for <linux-mm@kvack.org>; Wed, 13 May 2009 07:09:29 -0400 (EDT)
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu
From: Andi Kleen <andi@firstfloor.org>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com>
Date: Wed, 13 May 2009 13:09:32 +0200
In-Reply-To: <20090513172904.7234.A69D9226@jp.fujitsu.com> (KOSAKI Motohiro's message of "Wed, 13 May 2009 17:30:45 +0900 (JST)")
Message-ID: <87r5ytl0nn.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Minchan@firstfloor.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> writes:

> Subject: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu
>
> Almost people always turn on CONFIG_UNEVICTABLE_LRU. this configuration is
> used only embedded people.
> Thus, moving it into embedded submenu is better.

Is there are any reason it cannot be just made unconditional unless 
CONFIG_MMU is disabled. It was never clear to me why this was a config
option at all.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
