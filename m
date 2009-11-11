Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F139D6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 20:22:16 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAB1MAwl007076
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Nov 2009 10:22:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CE2645DE6F
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 10:22:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F140145DE4D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 10:22:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D9CED1DB803B
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 10:22:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9556A1DB803A
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 10:22:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/6] mm: CONFIG_MMU for PG_mlocked
In-Reply-To: <Pine.LNX.4.64.0911102155180.2816@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils> <Pine.LNX.4.64.0911102155180.2816@sister.anvils>
Message-Id: <20091111101315.FD33.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Nov 2009 10:22:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Remove three degrees of obfuscation, left over from when we had
> CONFIG_UNEVICTABLE_LRU.  MLOCK_PAGES is CONFIG_HAVE_MLOCKED_PAGE_BIT
> is CONFIG_HAVE_MLOCK is CONFIG_MMU.  rmap.o (and memory-failure.o)
> are only built when CONFIG_MMU, so don't need such conditions at all.
> 
> Somehow, I feel no compulsion to remove the CONFIG_HAVE_MLOCK*
> lines from 169 defconfigs: leave those to evolve in due course.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

I don't recall why Lee added this config option. but it seems very
reasonable and I storongly like it.

At least, vmscan folks never said "please try to disable CONFIG_MLOCK".
It mean this option didn't help our debug.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
