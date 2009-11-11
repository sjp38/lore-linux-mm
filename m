Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5034B6B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 07:38:38 -0500 (EST)
Date: Wed, 11 Nov 2009 13:38:30 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/6] mm: CONFIG_MMU for PG_mlocked
Message-ID: <20091111123829.GA16628@basil.fritz.box>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils> <Pine.LNX.4.64.0911102155180.2816@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0911102155180.2816@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 10, 2009 at 09:59:23PM +0000, Hugh Dickins wrote:
> Remove three degrees of obfuscation, left over from when we had
> CONFIG_UNEVICTABLE_LRU.  MLOCK_PAGES is CONFIG_HAVE_MLOCKED_PAGE_BIT
> is CONFIG_HAVE_MLOCK is CONFIG_MMU.  rmap.o (and memory-failure.o)
> are only built when CONFIG_MMU, so don't need such conditions at all.

Thanks.  The memory-failure.c change looks good and indeeds
it's overall less confusing.
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
