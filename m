Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B400A6B00C8
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 10:50:57 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2B2CB82C340
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 10:50:55 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qKBHvqHeyfcT for <linux-mm@kvack.org>;
	Fri, 20 Nov 2009 10:50:49 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 83EDA82C547
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 10:47:02 -0500 (EST)
Date: Fri, 20 Nov 2009 10:43:36 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH/RFC 0/6] Numa: Use Generic Per-cpu Variables for
 numa_*_id()
In-Reply-To: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.10.0911201041170.25879@V090114053VZO-1>
References: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 13 Nov 2009, Lee Schermerhorn wrote:

> Ad hoc measurements on x86_64 using:  hackbench 400 process 200
>
> 2.6.32-rc5+mmotm-091101		no patch	this series
> x86_64 avg of 40:		  4.605		  4.628  ~0.5%

Instructions become more efficient here.

> Ia64 showed ~1.2% longer time with the series applied.

IA64 can use the per cpu TLB entry to get to the numa node id with the
platform specific per cpu handling. The per cpu implementation
currently requires fallback. IA64 percpu ops could be reworked to avoid
consulting the per cpu offset arrray which would make it equivalent to the
current implementation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
