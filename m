Date: Thu, 27 Sep 2007 06:50:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] page->mapping clarification [1/3] base functions
Message-Id: <20070927065046.508d33c0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0709262015030.7064@blonde.wat.veritas.com>
References: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0709201120510.8801@schroedinger.engr.sgi.com>
	<20070921095054.6386bae1.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0709211716220.20783@blonde.wat.veritas.com>
	<20070922034234.bdb947e4.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0709262015030.7064@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, ricknu-0@student.ltu.se, magnus.damm@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, 26 Sep 2007 20:31:02 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:
> Would that waste a little memory?  I think not with SLUB,
> but perhaps with SLOB, which packs a little tighter.
> 

maybe just depends on the amount of used anon_vma and page_mapping_info etc...
I don't think a system which uses SLOB consumes such structs so much
as that memory-for-alignment is considered as "waste" of memory.

Anyway, I decided to go ahead with current container-info-per-page
implementation. If the size of page struct is problem at mainline inclusion
discussion, I'll be back.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
