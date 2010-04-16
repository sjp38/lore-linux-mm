Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 830986B0203
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 12:13:41 -0400 (EDT)
Date: Fri, 16 Apr 2010 11:13:10 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Interleave policy on 2M pages (was Re: [RFC][BUGFIX][PATCH 1/2]
 memcg: fix charge bypass route of migration)
In-Reply-To: <20100415081743.GP32034@random.random>
Message-ID: <alpine.DEB.2.00.1004161111380.7710@router.home>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp> <20100415120516.3891ce46.kamezawa.hiroyu@jp.fujitsu.com> <20100415154324.834dace9.nishimura@mxp.nes.nec.co.jp> <20100415155611.da707913.kamezawa.hiroyu@jp.fujitsu.com>
 <20100415081743.GP32034@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Apr 2010, Andrea Arcangeli wrote:

> 2) add alloc_pages_vma for numa awareness in the huge page faults

How do interleave policies work with alloc_pages_vma? So far the semantics
is to spread 4k pages over different nodes. With 2M pages this can no
longer work the way is was.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
