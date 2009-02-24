Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 47F016B00BF
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:26:54 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4B4F482C434
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:31:32 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id uXc4N60+ldme for <linux-mm@kvack.org>;
	Tue, 24 Feb 2009 12:31:27 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 73F8B82C43C
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:31:20 -0500 (EST)
Date: Tue, 24 Feb 2009 12:17:57 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 03/19] Do not check NUMA node ID when the caller knows
 the node is valid
In-Reply-To: <1235477835-14500-4-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0902241215460.32227@qirst.com>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235477835-14500-4-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

This is certainly reducing the number of branches that are inlined into
the kernel code.


Reviewed-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
