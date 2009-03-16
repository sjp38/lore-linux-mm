Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B27436B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 11:58:56 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9E32F30476C
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:05:37 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9DoAQknCDWRR for <linux-mm@kvack.org>;
	Mon, 16 Mar 2009 12:05:31 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B0F113046E4
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:05:29 -0400 (EDT)
Date: Mon, 16 Mar 2009 11:57:10 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 15/35] Inline __rmqueue_fallback()
In-Reply-To: <1237196790-7268-16-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903161156450.32577@qirst.com>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-16-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009, Mel Gorman wrote:

> __rmqueue() is in the slow path but has only one call site. It actually
> reduces text if it's inlined.

This is modifying __rmqueue_fallback() not __rmqueue().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
