Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id ED6C66B01EE
	for <linux-mm@kvack.org>; Wed, 12 May 2010 14:49:38 -0400 (EDT)
Date: Wed, 12 May 2010 11:49:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/8] numa: slab:  use numa_mem_id() for slab local
 memory node
Message-Id: <20100512114900.a12c4b35.akpm@linux-foundation.org>
In-Reply-To: <20100415173030.8801.84836.sendpatchset@localhost.localdomain>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
	<20100415173030.8801.84836.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi@domain.invalid, Kleen@domain.invalid, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

I have a note here that this patch "breaks slab.c".  But I don't recall what
the problem was and I don't see a fix against this patch in your recently-sent
fixup series?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
