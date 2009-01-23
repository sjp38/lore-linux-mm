Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 629376B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 08:35:11 -0500 (EST)
Date: Fri, 23 Jan 2009 13:34:49 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090123090042.GB19986@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0901231326520.9011@blonde.anvils>
References: <20090121143008.GV24891@wotan.suse.de> <1232613933.11429.127.camel@ymzhang>
 <20090123090042.GB19986@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Jan 2009, Nick Piggin wrote:
> 
> ... Would you be able to test with this updated patch
> (which also includes Hugh's fix ...

In fact not: claim_remote_free_list() still has the offending unlocked
+	VM_BUG_ON(!l->remote_free.list.head != !l->remote_free.list.tail);

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
