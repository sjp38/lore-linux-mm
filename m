From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Message-Id: <20051230223952.765.21096.sendpatchset@twins.localnet>
Subject: [PATCH] vm: page-replace and clockpro
Date: Fri, 30 Dec 2005 23:40:14 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Hi All,

These two patch sets implement a new page replacement algorithm based on
CLOCK-Pro.

The first patch set: page-replace-*, abstracts the current page replace code
and moves it to its own file: mm/page_replace.c.

The second patch set: clockpro-*, then implements a new replace algorithm by
reimplementing the hooks introduced in the previous set.


Andrew, Nick, the kswapd-incmin patch is there again ;-)
I know there is still some disagreement on this patch, however without
it reclaim truely sucks rock with this code.
What happens is that zone_dma is severly overscanned and the clockpro
implementation cannot handle this nicely.


PeterZ

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
