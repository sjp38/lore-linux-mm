Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F07176B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 05:48:11 -0500 (EST)
Date: Wed, 11 Nov 2009 10:48:07 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 3/6] mm: CONFIG_MMU for PG_mlocked
In-Reply-To: <20091111101315.FD33.A69D9226@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0911111042400.12126@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
 <Pine.LNX.4.64.0911102155180.2816@sister.anvils> <20091111101315.FD33.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009, KOSAKI Motohiro wrote:
> > Remove three degrees of obfuscation, left over from when we had
> > CONFIG_UNEVICTABLE_LRU.  MLOCK_PAGES is CONFIG_HAVE_MLOCKED_PAGE_BIT
> > is CONFIG_HAVE_MLOCK is CONFIG_MMU.  rmap.o (and memory-failure.o)
> > are only built when CONFIG_MMU, so don't need such conditions at all.
> 
> I don't recall why Lee added this config option. but it seems very
> reasonable and I storongly like it.
> 
> At least, vmscan folks never said "please try to disable CONFIG_MLOCK".
> It mean this option didn't help our debug.
> 
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks.  CONFIG_HAVE_MLOCKED_PAGE_BIT and CONFIG_HAVE_MLOCK were both
just internal, automatically defaulted options which the user never
saw (except in .config).  I think they were there to sort out the
interdependencies between CONFIG_MMU and CONFIG_UNEVICTABLE_LRU,
and probably other historical issues while people decided whether
or not to go ahead with having a page bit for the thing.  So no
user should notice their disappearance: removing them just makes
the code clearer, that's all.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
