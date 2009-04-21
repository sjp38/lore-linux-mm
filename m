Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 83E5D6B003D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:08:05 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2735E82C6B9
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:18:09 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jK61XhFO0KxZ for <linux-mm@kvack.org>;
	Tue, 21 Apr 2009 11:18:09 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7064782C6C2
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:18:04 -0400 (EDT)
Date: Tue, 21 Apr 2009 10:59:43 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 11/25] Calculate the cold parameter for allocation only
 once
In-Reply-To: <20090421180551.F142.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0904211058270.19969@qirst.com>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-12-git-send-email-mel@csn.ul.ie> <20090421180551.F142.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009, KOSAKI Motohiro wrote:

> It seems benefit is too small. It don't win against code ugliness, I think.

Some of these functions are inlined by the processor. And it helps the
compiler to optimize if the state is in a local variable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
