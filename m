Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFBC6B0023
	for <linux-mm@kvack.org>; Mon,  9 May 2011 18:18:17 -0400 (EDT)
Date: Mon, 9 May 2011 15:17:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] Add alloc_pages_exact_nid()
Message-Id: <20110509151745.476767e4.akpm@linux-foundation.org>
In-Reply-To: <1304716637-19556-1-git-send-email-andi@firstfloor.org>
References: <1304716637-19556-1-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>

On Fri,  6 May 2011 14:17:16 -0700
Andi Kleen <andi@firstfloor.org> wrote:

> Add a alloc_pages_exact_nid() that allocates on a specific node.

This conflicts in, I suspect, a more-than-textual manner with Dave's
http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-make-new-alloc_pages_exact.patch

Can you please take a look at that and work out what we should do?

As your [patch 2/2] fixes a regression, the answer might be "drop
Dave's patch".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
