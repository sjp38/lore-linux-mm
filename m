Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 576256B0022
	for <linux-mm@kvack.org>; Wed, 18 May 2011 17:39:56 -0400 (EDT)
Date: Wed, 18 May 2011 14:39:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] VM/RMAP: Add infrastructure for batching the rmap
 chain locking v2
Message-Id: <20110518143950.29d78f45.akpm@linux-foundation.org>
In-Reply-To: <20110518213556.GC12317@one.firstfloor.org>
References: <1305330384-19540-1-git-send-email-andi@firstfloor.org>
	<1305330384-19540-2-git-send-email-andi@firstfloor.org>
	<20110518132547.24d665e1.akpm@linux-foundation.org>
	<20110518211443.GB12317@one.firstfloor.org>
	<20110518142052.e0b6f327.akpm@linux-foundation.org>
	<20110518213556.GC12317@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, 18 May 2011 23:35:56 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> > ah, whoop, sorry.  It's getting turned into a mutex, by
> > mm-convert-anon_vma-lock-to-a-mutex.patch
> 
> Do you plan to merge that next cycle?

I expect so, yes.

> If yes I can rebase on top
> of that. Otherwise the other way round?

Well, I'm rather in shutdown-for-2.6.39 mode now anwyay.  So I'd
suggest that you wait and redo the patches on 2.6.40-rc1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
